use core::ptr::Unique;
use core::fmt;
use spin::Mutex;

const BUFFER_HEIGHT: usize = 25;
const BUFFER_WIDTH: usize = 80;

#[allow(dead_code)]
#[repr(u8)]
pub enum Color {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGray = 7,
    DarkGray = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    Pink = 13,
    Yellow = 14,
    White = 15,
}

#[derive(Clone, Copy)]
struct ColorCode(u8);

impl ColorCode {
    const fn new(foreground: Color, background: Color) -> ColorCode {
        ColorCode((background as u8) << 4 | (foreground as u8))
    }
}

#[repr(C)]
#[derive(Clone, Copy)]
struct ColoredChar {
    c: u8,
    color_code: ColorCode
}

struct Buffer {
    chars: [[ColoredChar; BUFFER_WIDTH]; BUFFER_HEIGHT],
}

pub struct Console {
    pos: usize,
    color_code: ColorCode,
    buffer: Unique<Buffer>,
}

impl Console {
    pub fn write_byte(&mut self, byte: u8) {
        match byte {
            b'\n' => self.new_line(),
            byte => {
                if self.pos >= BUFFER_WIDTH {
                    self.new_line();
                }

                let row = BUFFER_HEIGHT - 1;
                let col = self.pos;

                self.buffer().chars[row][col] = ColoredChar {
                    c: byte,
                    color_code: self.color_code,
                };
                self.pos += 1;
            }
        }
    }

    fn buffer(&mut self) -> &mut Buffer {
        unsafe { self.buffer.get_mut() }
    }

    fn new_line(&mut self) {
        for row in 0 .. (BUFFER_HEIGHT - 1) {
            let buffer = self.buffer();
            buffer.chars[row] = buffer.chars[row + 1];
        }
        self.clear_row(BUFFER_HEIGHT - 1);
        self.pos = 0;
    }

    fn clear_row(&mut self, row: usize) {
        let blank = ColoredChar {
            c: b' ',
            color_code: self.color_code,
        };
        self.buffer().chars[row] = [blank; BUFFER_WIDTH];
    }
}

impl fmt::Write for Console {
    fn write_str(&mut self, s: &str) -> fmt::Result {
        for byte in s.bytes() {
            self.write_byte(byte)
        }
        Ok(())
    }
}

pub static CONSOLE: Mutex<Console> = Mutex::new(Console {
    pos: 0,
    color_code: ColorCode::new(Color::LightGreen, Color::Black),
    buffer: unsafe { Unique::new(0xb8000 as *mut _) },
});

macro_rules! kprintln {
    ($fmt:expr) => (kprint!(concat!($fmt, "\n")));
    ($fmt:expr, $($arg:tt)*) => (kprint!(concat!($fmt, "\n"), $($arg)*));
}

macro_rules! kprint {
    ($($arg:tt)*) => ({
        use core::fmt::Write;
        $crate::console::CONSOLE.lock()
            .write_fmt(format_args!($($arg)*)).unwrap();
    });
}

pub fn clear_screen() {
    for _ in 0..BUFFER_HEIGHT {
        kprintln!("");
    }
}
