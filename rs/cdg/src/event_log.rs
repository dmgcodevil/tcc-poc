use std::fs::File;
use std::io;
use std::io::{BufRead, ErrorKind, Result, Write};
use std::io::{BufReader, Read, Seek, SeekFrom};
use std::slice::RSplit;

use bincode::config::BigEndian;
use bincode::Error;
use serde::{Deserialize, Serialize};

#[derive(Eq, Serialize, Deserialize, Debug)]
pub struct LogEntry {
    pub node_id: String,
    pub metadata_id: String,
    pub vector_clock: Vec<i32>,
    pub metadata_block: u64, // block position on disk
}

impl LogEntry {
    pub fn new(
        node_id: &str,
        metadata_id: &str,
        vector_clock: Vec<i32>,
        metadata_block: u64,
    ) -> LogEntry {
        LogEntry {
            node_id: node_id.to_string(),
            metadata_id: metadata_id.to_string(),
            vector_clock,
            metadata_block,
        }
    }

    // reads all entries from the file
    pub fn read_from_file(&self, file: &File) -> Result<Vec<LogEntry>> {
        Err(io::Error::new(io::ErrorKind::Other, "not implemented"))
    }

    // reads all entries starting from the given pos
    pub fn read_from_file_from_pos(&self, file: &File, pos: u64) -> Result<Vec<LogEntry>> {
        Err(io::Error::new(io::ErrorKind::Other, "not implemented"))
    }


    pub fn read_all() {}
    // reads 'n' entries from the given pos
    // n = 0 means read all entries
    pub fn read_from_file_from_pos_n(file: &File,
                                     pos: u64, n: u32) -> Result<Vec<LogEntry>> {
        let mut reader = BufReader::new(file);
        let mut remaining= n;

        reader.seek(SeekFrom::Start(pos))?;

        let mut entries = Vec::<LogEntry>::new();

        loop {
            if n > 0 && remaining == 0 {
                break;
            }
            if n > 0 {
                remaining = remaining - 1;
            }

            let len = match LogEntry::read_u64(&mut reader) {
                Ok(len) => len as usize,
                Err(ref err) if err.kind() ==
                    ErrorKind::UnexpectedEof =>
                    {
                        println!("EOF");
                        break; // Reached the end of the file
                    }

                Err(err) => return Err(io::Error::from(err)), // Propagate other errors
            };
            println!("read len={}", len);
            let mut buffer = vec![0u8; len];
            reader.read_exact(&mut buffer)?;

            let entry: LogEntry = bincode::deserialize(&buffer).unwrap(); // ? annoying: ^ the trait `From<Box<bincode::ErrorKind>>` is not implemented for `std::io::Error`
            entries.push(entry);
        }

        Ok(entries)
    }

    fn read_u64(reader: &mut BufReader<&File>) -> Result<u64> {
        let mut buf = [0; 8];
        reader.read_exact(&mut buf)?;
        Ok(u64::from_be_bytes(buf))
    }

    pub fn read_from_file_one(&self, file: &File, pos: u64) -> Result<LogEntry> {
        Err(io::Error::new(io::ErrorKind::Other, "not implemented"))
    }


    // Serialize the LogEntry and write it to a file
    pub fn write_to_file(&self, file: &mut File) -> Result<()> {
        let serialized = match bincode::serialize(self) {
            Ok(data) => data,
            Err(err) => return Err(io::Error::new(io::ErrorKind::Other, format!("Serialization error: {:?}", err))),
        };
        let length = serialized.len() as u64;
        println!("write {} bytes", length);

        // Write the length prefix
        file.write_all(&length.to_be_bytes())?;

        // Write the serialized LogEntry
        file.write_all(&serialized)?;

        Ok(())
    }
}

impl PartialEq for LogEntry {
    fn eq(&self, other: &Self) -> bool {
        self.node_id == other.node_id
            && self.metadata_id == other.metadata_id
            && self.vector_clock == other.vector_clock
            && self.metadata_block == other.metadata_block
    }
}

#[cfg(test)]
mod tests {
    use std::borrow::BorrowMut;
    use std::fs::OpenOptions;
    use std::io::prelude::*;
    use std::path;

    use tempfile::NamedTempFile;

    use super::*;

    #[test]
    fn test_write_read() {
        let entries = vec![LogEntry::new("1", "2",
                                         vec![1, 2, 3], 0)];
        let tmp_file = write_to_file(&entries).unwrap();
        let path = tmp_file.path();
        println!("path = {:?}", path);
        // Reopen the file for reading
        let file = File::open(path).expect("Failed to open the file for reading");

        let decoded_entries = LogEntry::read_from_file_from_pos_n(&file, 0, 0).unwrap();
        assert_eq!(entries, decoded_entries);
    }

    fn write_to_file(entries: &Vec<LogEntry>) -> Result<NamedTempFile> {
        let mut temp_file = NamedTempFile::new()?;
        let file = temp_file.as_file_mut();
        for e in entries {
            e.write_to_file(file)?;
        }
        Ok(temp_file)
    }
}