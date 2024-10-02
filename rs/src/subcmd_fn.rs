use clap::{
    Command,
    // Arg,
    // ArgAction,
    // arg,
    ArgMatches,
};

pub fn meta() -> Command {
    Command::new("rs-fn")
}

type NotClosure = fn();

fn execute_fn(f: NotClosure) {
    f();
}

fn foo() {
    println!("foo");
}

struct Hoge {
    s: String,
}

impl Hoge {
    fn new(s: &str) -> Self {
        Self {
            s: s.to_string(),
        }
    }
    fn bar(&self) {
        println!("{}", self.s);
    }
}

fn execute_cl<F>(f: F)
    where
        F: Fn(),
{
    f();
}

pub fn handler(_matches: &ArgMatches) -> Result<(), Box<dyn std::error::Error>> {
    execute_fn(foo);
    execute_fn(|| println!("bar"));
    // let s = "baz";
    // execute_fn(|| println!("{}", s));
    let h = Hoge::new("baz");
    // execute_fn(h.bar);
    execute_cl(|| h.bar());
    // let x = || h.bar();
    // let y = |s: String| println!("{}", s);
    Ok(())
}
