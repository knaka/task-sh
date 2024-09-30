// use anyhow::Context;
use clap::Command;
use list_files_macro::list_files;

pub fn register(command: Command) -> Command {
    command.subcommand(Command::new("fs")
        .about("fs command")
    )
}

pub fn run(_arg_matches: &clap::ArgMatches) -> Result<(), Box<dyn std::error::Error>> {
    println!("Hello!");
    let results: [_; 0] = list_files!("/tmp/foo/*");
    for file in results {
        println!("file: {}", file);
    }
    Ok(())
}
