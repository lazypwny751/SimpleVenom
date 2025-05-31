use crossterm::event::{self, Event, KeyCode};
use ratatui::{DefaultTerminal, Frame};
use crate::i10n::transcript::TranscriptinTable;

pub fn res(mut terminal: DefaultTerminal, language: &String) -> Result<(), Box<dyn std::error::Error>> {
    loop {
		let _ = terminal.draw(|frame| render(frame, language));
        if let Event::Key(key_event) = event::read().unwrap() {
			if let KeyCode::Char('q') = key_event.code {
            	break Ok(());
			}
        }
    }
}

fn render(frame: &mut Frame, language: &String) {
    frame.render_widget(TranscriptinTable::localize("hello world", language), frame.area());
}
