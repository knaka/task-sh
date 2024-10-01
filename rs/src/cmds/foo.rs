use clap::{Arg, Command};

pub fn register(command: Command) -> Command {
    command.subcommand(Command::new("rsfoo")
        .about("foo command")
        .arg(Arg::new("files")
            .num_args(1..)
        )
    )
}

pub fn run(arg_matches: &clap::ArgMatches) -> Result<(), Box<dyn std::error::Error>> {
    let files = arg_matches.get_many::<String>("files").unwrap();
    for file in files {
        println!("file: {}", file);
    }
    Ok(())
}
