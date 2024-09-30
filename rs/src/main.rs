use anyhow::Context;

mod cmds;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    std::env::set_var("RUST_BACKTRACE", "FULL");
    let (mut cmd_root, sub_cmd_fns) = cmds::init();
    cmd_root = cmd_root
        .name("app")
        .about("app command")
        .version("0.1.2")
    ;
    return match cmd_root.get_matches().subcommand() {
        Some((name, sub_arg_matches)) => {
            sub_cmd_fns.get(name).context("39aec96")?(sub_arg_matches)
        }
        _ => {
            Err("No subcommand provided".into())
        }
    };
}
