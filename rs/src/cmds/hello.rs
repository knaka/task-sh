use anyhow::Context;
use clap::{Arg, Command};

pub fn register(command: Command) -> Command {
    command.subcommand(Command::new("hello")
        .about("hello command")
        .arg(Arg::new("name")
            .short('n')
            .long("name")
            .value_name("NAME")
            .default_value("World")
        )
    )
}

pub fn run(arg_matches: &clap::ArgMatches) -> Result<(), Box<dyn std::error::Error>> {
    println!("Hello, {}!", arg_matches.get_one::<String>("name").context("995902b")?);
    Ok(())
}
