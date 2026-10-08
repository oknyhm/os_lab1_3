"""Lossless dialogue crops; never read the credential-bearing original."""
import hashlib
import json
import math
from pathlib import Path

from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'ai-record' / 'report-crops'
SOURCES = [
    ('询问实验难度.png', 'selection'),
    ('检查配置以及书写方案_已脱敏.png', 'plan'),
    ('执行.png', 'execution'),
    ('完成.png', 'completion'),
]


def main():
    OUT.mkdir(exist_ok=True)
    records = []
    for filename, prefix in SOURCES:
        source = ROOT / 'ai-record' / filename
        with Image.open(source) as opened:
            original = opened.convert('RGB')
        width, height = original.size
        count = math.ceil(height / 1900)
        bounds = [0]
        for index in range(1, count):
            target = round(height * index / count)
            candidates = range(max(bounds[-1] + 1, target - 100), min(height, target + 101))
            # Prefer a blank inter-line row, then the nearest balanced boundary.
            def score(y):
                row = original.crop((0, y, width, y + 1))
                ink = sum(min(pixel) < 210 for pixel in row.getdata())
                return ink, abs(y - target)
            bounds.append(min(candidates, key=score))
        bounds.append(height)
        reconstructed = Image.new('RGB', original.size)
        for index, (top, bottom) in enumerate(zip(bounds, bounds[1:]), 1):
            crop = original.crop((0, top, width, bottom))
            name = f'{prefix}-{index:02d}.png'
            crop.save(OUT / name)
            with Image.open(OUT / name) as saved:
                reconstructed.paste(saved, (0, top))
            records.append({'source': f'ai-record/{filename}', 'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(), 'crop': f'ai-record/report-crops/{name}', 'box_xyxy': [0, top, width, bottom], 'part': index, 'parts': count})
        assert ImageChops.difference(original, reconstructed).getbbox() is None
        print(f'{filename}: {count} parts; reconstructed pixels identical')
    (OUT / 'crop-map.json').write_text(json.dumps(records, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


if __name__ == '__main__':
    main()
