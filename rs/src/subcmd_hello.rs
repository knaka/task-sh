use clap::{Command, Arg, ArgAction, arg, ArgMatches};

pub fn meta() -> Command {
    Command::new("rs-hello")
        .about("Greet the user")
        .args([
            (arg!(-n --name <NAME> "The name to greet") as Arg).default_value("world"),
            Arg::new("name2")
                .short('N')
                .long("name2")
                .value_name("NAME")
                .help("The name to greet")
                .default_value("world")
                .required(false),
            Arg::new("uppercase")
                .short('u')
                .long("uppercase")
                .action(ArgAction::SetTrue)
                .help("Uppercase the output")
                .required(false),
        ])
}

pub fn handler(matches: &ArgMatches) -> Result<(), Box<dyn std::error::Error>> {
    let uppercase = matches.get_flag("uppercase");
    let name = matches.get_one::<String>("name").unwrap();
    if uppercase {
        println!("HELLO, {}!", name.to_uppercase());
    } else {
        println!("Hello, {}!", name);
    }
    Ok(())
}
