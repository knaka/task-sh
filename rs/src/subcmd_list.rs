use ctor::ctor;
use crate::SUBCOMMANDS;

#[ctor]
fn init() {
    let mut subcommands = SUBCOMMANDS.lock().unwrap();
    subcommands.insert("list", |_arg_matches| {
        for (name, _) in SUBCOMMANDS.lock().unwrap().iter() {
            println!("{}", name);
        }
        Ok(())
    });
}
