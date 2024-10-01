use ctor::ctor;
use crate::ROOT_COMMAND;
use clap::{Command, Arg, ArgAction, arg};

#[ctor]
fn init() {
    const NAME: &str = "rs-hello";
    // clap::_tutorial - Rust https://docs.rs/clap/4.5.18/clap/_tutorial/index.html
    // let args: Vec<Arg> = vec![];
    // let arg: Arg = arg!(-v --verbose "Print test information verbosely"); arg.default_value("xxx").required(false);
    // args.push(arg);
    ROOT_COMMAND.lock().unwrap().register(
        NAME,
        Command::new(NAME)
            .about("Greets the user.")
            // .arg(arg!(-n --name <NAME> "The name to greet").default_value("world").required(false))
            .args([
                (arg!(-n --name <NAME> "The name to greet") as Arg).default_value("world"),
                Arg::new("name2")
                    .short('N')
                    .long("name2")
                    .value_name("NAME")
                    .help("The name to greet")
                    .default_value("world")
                    .required(false)
                ,
                Arg::new("uppercase")
                    .short('u')
                    .long("uppercase")
                    .action(ArgAction::SetTrue)
                    .help("Uppercase the output")
                ,
            ])
        ,
        |matches| {
            let uppercase = matches.get_flag("uppercase");
            let name = matches.get_one::<String>("name").unwrap();
            if uppercase {
                println!("HELLO, {}!", name.to_uppercase());
            } else {
                println!("Hello, {}!", name);
            }
            Ok(())
        },
    );
}
