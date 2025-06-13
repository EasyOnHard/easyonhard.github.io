---
title: Myfetch
date: 2025-06-12
---
## Myfetch
I spent the majority of my day on this project -- and it was well worth it!

```zsh
❯ hyperfine 'target/release/myfetch' 'fastfetch -c ~/.config/fastfetch/config\ \(Copy\).jsonc --logo none' 'neofetch --fast --off'
Benchmark 1: target/release/myfetch
  Time (mean ± σ):     609.1 µs ± 103.2 µs    [User: 491.5 µs, System: 478.5 µs]
  Range (min … max):   353.1 µs … 1058.0 µs    1981 runs
 
  Warning: Command took less than 5 ms to complete. Note that the results might be inaccurate because hyperfine can not calibrate the shell startup time much more precise than this limit. You can try to use the `-N`/`--shell=none` option to disable the shell completely.
 
Benchmark 2: fastfetch -c ~/.config/fastfetch/config\ \(Copy\).jsonc --logo none
  Time (mean ± σ):       9.4 ms ±   0.3 ms    [User: 1.2 ms, System: 8.0 ms]
  Range (min … max):     8.7 ms …  10.7 ms    270 runs
 
Benchmark 3: neofetch --fast --off
  Time (mean ± σ):     176.8 ms ±   1.5 ms    [User: 105.2 ms, System: 79.2 ms]
  Range (min … max):   174.0 ms … 180.0 ms    17 runs
 
Summary
  target/release/myfetch ran
   15.51 ± 2.68 times faster than fastfetch -c ~/.config/fastfetch/config\ \(Copy\).jsonc --logo none
  290.25 ± 49.22 times faster than neofetch --fast --off
```
(Note: I won't bring Neofetch back up, and this benchmark is technically rigged because they are both still outputting more info, but that is the Myfetch _charm_.)

This is with v1.0.0. Compare that to the first prototype:
```zsh
Summary 
  fastfetch -c ~/.config/fastfetch/config\ \(Copy\).jsonc ran 
   13.48 ± 0.48 times faster than target/release/myfetch
```

Which is bad. The issue was that I was polling my entire system, not just what I needed, which was stupid.  

### Optimizations
The first time I removed some of the bloat was when I made my own function to fetch memory information, which brought Fastfetch only `9.89 ± 0.29` times faster from `9.92 ± 0.30`, which might be a fluke but it was a win, especially long term. It made some of the later optimizations possible!

I beat Fastfetch with this:
```zsh
Summary
  target/release/myfetch ran
    8.39 ± 1.04 times faster than fastfetch -c ~/.config/fastfetch/config\ \(Copy\).jsonc
```

I was running `let mut sys = System::new_all();` instead of `let mut sys = System::new();`, and then I was refreshing on top of that! Oops!

After that, thw program plateaued at ~1.1ms, though I brought it down to `375.4 µs to 1059.1 µs` when I removed `let mut sys = System::new();`, so no more polling!

Right now, the only call to sysinfo is here:
```rust
    {
        // KERNEL
        let kernel = System::kernel_version().unwrap_or("Unknown".into());
        print_formatted("Kernel", &kernel);
    }
```

Making one call is not that bad, and getting rid of it would just mean more work on my side.

The output:
```zsh
easyonhard@arch
Kernel: 6.12.31-1-lts
OS: Arch Linux (x86_64)
Shell: /usr/bin/zsh
Uptime: 11 hours, 56 minutes
Memory: 5.21 GiB / 31.19 GiB (16.7%)
```

It has a bit of formatting, but markdown doesn't pick it up in code blocks.

---

Disclaimer: I don't review these. This is my brain regurgitating onto my keyboard out off my nose.