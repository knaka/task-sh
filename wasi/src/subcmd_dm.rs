use clap::{
    Command,
    Arg,
    ArgAction,
    ArgMatches,
    arg,
};

pub fn meta() -> Command {
    Command::new("wasi-dm")
        .about("Dump")
        .args([
            (arg!(-v --verbose "Verbose output") as Arg).action(ArgAction::SetTrue),
            Arg::new("file")
                .help("Files to read. - or missing for stdin")
                .action(ArgAction::Append)
        ])
}

use std::io::{self, BufReader, Read, Write};
use anyhow::{Result, Context};

const BYTES_PER_LINE: usize = 16;
const CH_NOT_PRINTABLE: char = '.';

const ESC_SEQ_RED: &str = "\x1b[31m";
const ESC_SEQ_RESET: &str = "\x1b[0m";

fn dump_file<R: std::io::Read>(input_stream: R) -> Result<(), Box<dyn std::error::Error>> {
    let mut reader = BufReader::new(input_stream);
    let stdout = io::stdout();
    let mut writer = stdout.lock();
    let colored = atty::is(atty::Stream::Stdout);
    let mut buf = vec![0; BYTES_PER_LINE];
    let mut addr = 0;
    loop {
        let bytes_read = reader.read(&mut buf)?;
        if bytes_read == 0 {
            break;
        }
        let mut hexes = Vec::new();
        let mut readable = String::new();
        for i in 0..BYTES_PER_LINE {
            if i < bytes_read {
                hexes.push(format!("{:02X}", buf[i]));
                if buf[i].is_ascii_graphic() {
                    readable.push(buf[i] as char);
                } else {
                    if colored {
                        readable.push_str(ESC_SEQ_RED);
                        readable.push(CH_NOT_PRINTABLE);
                        readable.push_str(ESC_SEQ_RESET);
                    } else {
                        readable.push(CH_NOT_PRINTABLE);
                    }
                }
            } else {
                hexes.push("  ".to_string());
                readable.push(' ');
            }
        }
        writeln!(
            writer,
            "{:08X} | {} | {}",
            addr,
            hexes.join(" "),
            readable
        )?;
        addr += BYTES_PER_LINE;
    }
    Ok(())
}

const STDIN_FILENAME: &str = "-";

type InputStream = Box<dyn Read>;

use std::env::set_var;

pub fn handler(matches: &ArgMatches) -> Result<(), Box<dyn std::error::Error>> {
    let verbose = matches.get_flag("verbose");
    if verbose {
        unsafe { set_var("RUST_BACKTRACE", "full") };
    }
    if verbose {
        // Show the current working directory.
        let cwd = std::env::current_dir().context("8f4419e")?;
        println!("Current working directory: {}", cwd.display());
    }
    let files: Vec<String> = matches
        .get_many::<String>("file")
        .map(|args| args.cloned().collect())
        .unwrap_or_else(|| vec![STDIN_FILENAME.to_string()])
    ;
    for file in files {
        let input_stream = if file == STDIN_FILENAME {
            Box::new(std::io::stdin()) as InputStream
        } else {
            let mut original_dir = "/".to_string();
            if let Ok(original_dir_env) = std::env::var("ORIGINAL_DIR") {
                original_dir = original_dir_env;
            }
            // If `file` is a relative path, prepend the original directory.
            let file2 = if file.starts_with("/") {
                file.clone()
            } else {
                format!("{}/{}", original_dir, file)
            };
            Box::new(std::fs::File::open(file2).context("8493036")?) as InputStream
        };
        dump_file(input_stream)?;
    }
    Ok(())
}
