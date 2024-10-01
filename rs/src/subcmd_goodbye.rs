use ctor::ctor;
use crate::SUBCOMMANDS;

#[ctor]
fn init() {
    let mut commands = SUBCOMMANDS.lock().unwrap();
    commands.insert("rs-goodbye", |_arg_matches| {
        println!("Goodbye, world!");
        Ok(())
    });
}
