use clap::{Command, Arg, ArgAction, arg, ArgMatches};



pub fn meta() -> Command {
    Command::new("rs-empty")
        .about("Greet the user")
        .args([
            (arg!(-n --name <NAME> "The name to greet") as Arg).default_value("world"),
            (arg!(-u --uppercase "Uppercase the output") as Arg).action(ArgAction::SetTrue),
        ])
}

pub fn handler(matches: &ArgMatches) -> Result<(), Box<dyn std::error::Error>> {
    let uppercase = matches.get_flag("uppercase");
    let name = matches.get_one::<String>("name").unwrap();
    let output = format!("Hello, {}!", name);
    println!("{}", if uppercase { output.to_uppercase() } else { output });
    Ok(())
}
