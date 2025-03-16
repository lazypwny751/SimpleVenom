mod tui;
mod args;
mod i10n;
mod exploit;

use clap::Parser;
use args::Args;
use exploit::options::TaskStruct;
use i10n::transcript::TranscriptinTable;
use tui::master::run;

fn main() -> Result<(), Box<dyn std::error::Error>> {
	let args = Args::parse();
    println!("{}", TranscriptinTable::localize("hello world", &args.lang));

    let terminal = ratatui::init();
    let result = run(terminal, &args.lang);
    ratatui::restore();

    Ok(result?)
}
