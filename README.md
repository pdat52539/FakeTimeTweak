# FakeTimeTweak

![iOS](https://img.shields.io/badge/iOS-15--16-brightgreen) ![Rootless](https://img.shields.io/badge/rootless-Dopamine-blue) ![arch](https://img.shields.io/badge/arch-arm64-lightgrey)

Tweak jailbreak iOS hook hệ thống thời gian, luôn trả về `00:00:00 ngày 01/01/2000`. Hỗ trợ chọn app cụ thể qua Settings. Tương thích Dopamine (rootless).

## Tính năng

- Fake toàn bộ thời gian hệ thống về `2000-01-01 00:00:00 UTC`
- Hook `NSDate`, `gettimeofday`, `clock_gettime`, `CFAbsoluteTimeGetCurrent`, `mach_absolute_time`
- Preferences pane trong Settings — bật/tắt tweak và chọn app cụ thể
- Build rootless, tương thích Dopamine beta 4+
- Không làm treo SpringBoard

## Yêu cầu

| Thành phần | Phiên bản |
|---|---|
| iOS | 15.0 – 16.7.x |
| Jailbreak | Dopamine beta 4+ (rootless) |
| Kiến trúc | arm64 |
| Depends | MobileSubstrate / PreferenceLoader |

## Cài đặt

### Cách 1 — Tải file .deb trực tiếp

1. Vào trang **Releases** của repo này
2. Tải file `.deb` mới nhất
3. AirDrop sang iPhone → mở bằng **Filza** hoặc **Sileo**
4. Respring

### Cách 2 — Thêm repo vào Sileo

```
https://pdat52539.github.io/repo
```

## Build từ mã nguồn

```bash
git clone https://github.com/pdat52539/FakeTimeTweak
cd FakeTimeTweak
./build.sh
```

Yêu cầu [Theos](https://theos.dev) đã cài trên macOS hoặc Linux.

## Cấu trúc project

```
FakeTimeTweak/
├── Tweak.x                 ← Logic hook chính
├── Makefile
├── control
├── FakeTimeTweak.plist
├── build.sh
└── FakeTimePrefs/          ← Preferences bundle
    ├── Makefile
    ├── FakeTimePrefsListController.h
    ├── FakeTimePrefsListController.m
    └── Resources/
```

## License

MIT License © 2025 pdat52539
