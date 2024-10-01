use clap::Command;

pub fn register(
    command: Command,
    command_map: &mut std::collections::HashMap<&str, fn(&clap::ArgMatches) -> Result<(),Box<dyn std::error::Error>>
) -> Command {
    let cmd = Command::new("rs-hello")
        .about("Hello command");
    command_map.insert("rs-hello", |arg_matches| {
        println!("Hello, world!");
        Ok(())
    });
    return command.subcommand(cmd);
}

