mod tui;
mod i10n;
mod exploit;

use clap::Parser;
use tui::master::res;

#[derive(Parser, Debug)]
#[command(version, about = "SimpleVenom by ByCh4n", long_about = "Create exploits easily.")]
pub struct Args {
	#[arg(long, short, default_value = "en")]
	pub lang: String,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
	let args = Args::parse();

    let terminal = ratatui::init();
    let result = res(terminal, &args.lang);
    ratatui::restore();

    Ok(result?)
}
