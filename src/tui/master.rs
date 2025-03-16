use crossterm::event::{self, Event};
use ratatui::{DefaultTerminal, Frame};
use crate::i10n::transcript::TranscriptinTable;

pub fn run(mut terminal: DefaultTerminal, language: &String) -> Result<(), Box<dyn std::error::Error>> {
    loop {
        // terminal.draw(render)?;
        let _ = terminal.draw(|frame| render(frame, language));
        if matches!(event::read()?, Event::Key(_)) {
            break Ok(());
        }
    }
}

fn render(frame: &mut Frame, language: &String) {
    frame.render_widget(TranscriptinTable::localize("hello world", language), frame.area());
}
