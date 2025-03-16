mod tui;
mod args;
mod i10n;
mod exploit;

use clap::Parser;
use args::Args;
use exploit::options::TaskStruct;
use i10n::transcript::TranscriptinTable;

fn main() {
	let args = Args::parse();

    println!("{}", TranscriptinTable::localize("hello world", &args.lang));
}
