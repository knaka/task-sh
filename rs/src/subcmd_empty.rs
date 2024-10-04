use clap::{
    Command,
    ArgMatches,
};

pub fn meta() -> Command {
    Command::new("rs-empty")
}

pub fn handler(_matches: &ArgMatches) -> Result<(), Box<dyn std::error::Error>> {
    Ok(())
}
