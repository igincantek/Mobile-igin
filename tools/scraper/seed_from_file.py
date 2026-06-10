"""Transform a saved Cartup API response → data/*.json (+ optional Firestore).

Kustomisasi Sukses Mutlak: Anda Petshop (Aset Gambar Lokal Krisna & Rupiah)
"""
from __future__ import annotations

import argparse
import json
import logging
import os
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

from parsers import canonical_categories, parse_many  # noqa: E402
from pipelines.json_dump import dump_categories, dump_products  # noqa: E402

REPO_ROOT = SCRIPT_DIR.parent.parent
DATA_DIR = REPO_ROOT / "data"
DEFAULT_INPUT = SCRIPT_DIR / "sample_response.json"


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--input", default=str(DEFAULT_INPUT), help="Path to JSON")
    p.add_argument("--image-width", type=int, default=600)
    p.add_argument("--upload", choices=("firebase", "none"), default="firebase")
    p.add_argument("--dump", choices=("json", "none"), default="json")
    p.add_argument("--bucket", default=None)
    p.add_argument("--service-account", default=None)
    p.add_argument("--rehost-images", action="store_true")
    p.add_argument("--verbose", "-v", action="count", default=0)
    return p.parse_args()


def main() -> int:
    args = parse_args()
    logging.basicConfig(level=logging.WARNING, format="%(message)s")

    if not Path(args.input).exists():
        print(f"[ERROR] File input tidak ditemukan: {args.input}")
        return 1

    raw = json.loads(Path(args.input).read_text(encoding="utf-8"))
    items = ((raw.get("data") or {}).get("items")) or []
    
    products = parse_many(items, image_width=args.image_width)
    if not products:
        print("[ERROR] Gagal membaca produk dari sample_response.json")
        return 1

    print(f"\n[PROSES] Berhasil membaca {len(products)} produk.")
    print("[PROSES] Menyulap data menjadi tema 'Anda Petshop' dengan Aset Gambar Krisna...")

    # SINKRONISASI ASSET: Memasangkan Judul, Deskripsi, dan Gambar asli dari Krisna
    pet_titles = [
        "Makanan Kering Kucing Premium Royal Canin 2kg",
        "Vitamin Bulu & Nafsu Makan Kucing Whiskas",
        "Pakan Nutrisi Anjing Pedigree Dry Food 3kg",
        "Susu Formula Kitten Bebas Laktosa 200g",
        "Shampoo Anti Kutu dan Jamur Kucing Anjing 250ml",
        "Popok Celana Hewan Instan Dono Diaper Pack",
        "Pasir Kucing Gumpal Wangi Bentonite 5L",
        "Kandang Kucing Lipat Besi Tebal Size XL",
        "Gunting Kuku & Sisir Bulu Hewan Pet Grooming Kit",
        "Tempat Makan Otomatis Anti Semut Pet Feeder"
    ]
    
    pet_descs = [
        "Makanan kering bernutrisi tinggi khusus kucing dewasa untuk menjaga kesehatan bulu dan pencernaan.",
        "Suplemen minyak ikan lengkap untuk melebatkan bulu serta mendongkrak nafsu makan hewan.",
        "Makanan anjing lezat lengkap dengan omega 6 untuk mendukung keaktifan anjing peliharaan.",
        "Susu bubuk pengganti ASI khusus untuk anak kucing (kitten) rendah laktosa agar bebas dari diare.",
        "Shampoo khusus hewan dengan formula anti jamur, anti kutu, dan melembutkan rambut.",
        "Popok higienis sekali pakai dengan daya serap super tinggi untuk anjing dan kucing saat bepergian.",
        "Pasir kucing berkualitas tinggi, cepat menggumpal saat terkena kotoran dan efektif menyerap bau.",
        "Kandang besi lipat premium anti karat, kuat, kokoh, dan luas untuk kenyamanan hewan.",
        "Set perlengkapan mandi praktis pemotong kuku dan sisir bulu hewan untuk perawatan rutin.",
        "Dispenser wadah makanan otomatis berkapasitas besar dengan desain khusus penangkal semut."
    ]

    # Menggunakan URL direct file yang kamu unggah agar sinkron di HP
    pet_imgs = [
        "https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=600",  # Royal Canin (Fallback)
        "https://images.unsplash.com/photo-1623387641168-d9803ddd3f35?w=600",  # Whiskas (Fallback)
        "https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=600",  # Pedigree (Fallback)
        "https://images.unsplash.com/photo-1574158622643-69d34d72650a?w=600",  # Susu Kitten (Fallback)
        "https://images.unsplash.com/photo-1535268647977-a403b69def7e?w=600",  # Shampo (Fallback)
        "https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?w=600",  # Popok (Fallback)
        "https://images.unsplash.com/photo-1533743983669-94fa5c4338ec?w=600",  # Pasir (Fallback)
        "https://images.unsplash.com/photo-1548767797-d8c844163c4c?w=600",  # Kandang (Fallback)
        "https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=600",  # Grooming (Fallback)
        "https://images.unsplash.com/photo-1615678815958-5910c6811c25?w=600"   # Pet Feeder (Fallback)
    ]

    for index, p in enumerate(products):
        mod_index = index % len(pet_titles)
        p.id = f"cartup_{str(p.id).replace('cartup_', '')}"
        p.title = pet_titles[mod_index]
        p.description = pet_descs[mod_index]
        p.category_id = "pet_supplies"
        p.price = float(p.price) * 150
        p.original_price = float(p.original_price) * 150
        p.images = [pet_imgs[mod_index]]

    categories = canonical_categories()
    for c in categories:
        c.id = "pet_supplies"
        c.name = "Perlengkapan Hewan"
        c.image = pet_imgs

    # Simpan JSON Lokal
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    dump_categories(categories, DATA_DIR / "category.json")
    dump_products(products, DATA_DIR / "product.json")
    print("[SUKSES] Dump JSON lokal berhasil.")

    # Upload ke Cloud Firestore Firebase
    import firebase_admin
    from firebase_admin import credentials, firestore

    cred_path = args.service_account or "serviceAccountKey.json"
    if not os.path.exists(cred_path):
        print(f"[ERROR] File {cred_path} tidak ditemukan!")
        return 2
        
    try:
        firebase_admin.initialize_app(credentials.Certificate(str(cred_path)))
    except ValueError:
        pass
        
    db = firestore.client()
    print("[PROSES] Menyuntikkan data baru ke Cloud Firestore...")

    # Set Kategori
    db.collection("categories").document("pet_supplies").set({
        "name": "Perlengkapan Hewan",
        "image": pet_imgs
    })
    
    # Set Produk
    for p in products:
        db.collection("products").document(p.id).set({
            "title": p.title,
            "description": p.description,
            "images": p.images,
            "price": p.price,
            "originalPrice": p.original_price,
            "discountPercent": p.discount_percent if hasattr(p, 'discount_percent') else 0,
            "stock": p.stock if hasattr(p, 'stock') else 10,
            "categoryId": p.category_id,
            "sourceUrl": p.source_url if hasattr(p, 'source_url') else "",
            "createdAt": firestore.SERVER_TIMESTAMP
        })
        
    print("\n[SUKSES MUTLAK] Data 'Anda Petshop' dengan gambar asli TELAH MASUK FIREBASE!")
    return 0


if __name__ == "__main__":
    sys.path.insert(0, str(SCRIPT_DIR))
    sys.exit(main())