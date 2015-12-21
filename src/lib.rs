#![feature(lang_items)]
#![feature(const_fn, unique)]
#![no_std]
#![allow(dead_code)]

extern crate rlibc;
extern crate spin;

#[macro_use]
mod console;

#[no_mangle]
pub extern fn kmain(multiboot_information_address: usize) {
    console::clear_screen();
    kprint!("Hello, world{}", "!");
    kprintln!("multiboot information address {}",
              multiboot_information_address);

    loop {}
}

#[lang = "eh_personality"] extern fn eh_personality() {}
#[lang = "panic_fmt"] extern fn panic_fmt() -> ! {loop {}}
