#include <substrate.h>
#include <sys/time.h>
#include <time.h>
#include <mach/mach_time.h>
#include <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>

#define FAKE_CF_ABSOLUTE  (-31536000.0)
#define FAKE_UNIX_EPOCH   946684800UL
#define FAKE_MACH_NANOS   (946684800ULL * 1000000000ULL)
#define PREFS_ID          CFSTR("com.yourname.faketimetweak")

// ─── Kiểm tra app hiện tại có được bật hook không ───
static BOOL shouldHook(void) {
    // Đọc pref: tweak có bật không?
    CFPropertyListRef enabled = CFPreferencesCopyAppValue(CFSTR("enabled"), PREFS_ID);
    if (enabled && CFGetTypeID(enabled) == CFBooleanGetTypeID()) {
        if (!CFBooleanGetValue((CFBooleanRef)enabled)) {
            CFRelease(enabled);
            return NO;  // Tweak bị tắt toàn bộ
        }
        CFRelease(enabled);
    }

    // Đọc danh sách app được chọn
    CFPropertyListRef appList = CFPreferencesCopyAppValue(CFSTR("selectedApps"), PREFS_ID);
    if (!appList) return YES;  // Chưa cài đặt → hook tất cả

    NSString *currentBundle = [[NSBundle mainBundle] bundleIdentifier];
    BOOL found = NO;

    if (CFGetTypeID(appList) == CFDictionaryGetTypeID()) {
        NSDictionary *dict = (__bridge NSDictionary *)appList;
        found = [dict[currentBundle] boolValue];
    }

    CFRelease(appList);
    return found;
}

// ─── NSDate ─────────────────────────────────────────
%hook NSDate

+ (instancetype)date {
    if (!shouldHook()) return %orig;
    return [NSDate dateWithTimeIntervalSinceReferenceDate:FAKE_CF_ABSOLUTE];
}

+ (instancetype)dateWithTimeIntervalSinceNow:(NSTimeInterval)secs {
    if (!shouldHook()) return %orig(secs);
    return [NSDate dateWithTimeIntervalSinceReferenceDate:FAKE_CF_ABSOLUTE];
}

+ (instancetype)dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval)ti {
    if (!shouldHook()) return %orig(ti);
    return %orig(FAKE_CF_ABSOLUTE);
}

+ (instancetype)dateWithTimeIntervalSince1970:(NSTimeInterval)secs {
    if (!shouldHook()) return %orig(secs);
    return %orig((NSTimeInterval)FAKE_UNIX_EPOCH);
}

%end

// ─── CFAbsoluteTimeGetCurrent ────────────────────────
static CFAbsoluteTime (*orig_CFAbsoluteTimeGetCurrent)(void);
static CFAbsoluteTime fake_CFAbsoluteTimeGetCurrent(void) {
    return shouldHook() ? (CFAbsoluteTime)FAKE_CF_ABSOLUTE
                        : orig_CFAbsoluteTimeGetCurrent();
}

// ─── gettimeofday ────────────────────────────────────
static int (*orig_gettimeofday)(struct timeval *, struct timezone *);
static int fake_gettimeofday(struct timeval *tv, struct timezone *tz) {
    if (!shouldHook()) return orig_gettimeofday(tv, tz);
    if (tv) { tv->tv_sec = (time_t)FAKE_UNIX_EPOCH; tv->tv_usec = 0; }
    if (tz) { tz->tz_minuteswest = 0; tz->tz_dsttime = 0; }
    return 0;
}

// ─── clock_gettime ───────────────────────────────────
static int (*orig_clock_gettime)(clockid_t, struct timespec *);
static int fake_clock_gettime(clockid_t clk_id, struct timespec *ts) {
    if (!ts) return -1;
    if (!shouldHook()) return orig_clock_gettime(clk_id, ts);
    switch (clk_id) {
        case CLOCK_REALTIME:
        case CLOCK_MONOTONIC:
            ts->tv_sec = (time_t)FAKE_UNIX_EPOCH; ts->tv_nsec = 0;
            return 0;
        default:
            return orig_clock_gettime(clk_id, ts);
    }
}

// ─── mach_absolute_time ──────────────────────────────
static uint64_t (*orig_mach_absolute_time)(void);
static uint64_t fake_mach_absolute_time(void) {
    return shouldHook() ? FAKE_MACH_NANOS : orig_mach_absolute_time();
}

%ctor {
    MSHookFunction((void *)CFAbsoluteTimeGetCurrent,
                   (void *)fake_CFAbsoluteTimeGetCurrent,
                   (void **)&orig_CFAbsoluteTimeGetCurrent);
    MSHookFunction((void *)gettimeofday,
                   (void *)fake_gettimeofday,
                   (void **)&orig_gettimeofday);
    MSHookFunction((void *)clock_gettime,
                   (void *)fake_clock_gettime,
                   (void **)&orig_clock_gettime);
    MSHookFunction((void *)mach_absolute_time,
                   (void *)fake_mach_absolute_time,
                   (void **)&orig_mach_absolute_time);
}
