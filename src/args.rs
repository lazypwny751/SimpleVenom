use clap::Parser;

#[derive(Parser, Debug)]
#[command(version, about = "SimpleVenom by ByCh4n", long_about = "Create exploits easily.")]
pub struct Args {
	#[arg(long, short, default_value = "en")]
	pub lang: String,
}
