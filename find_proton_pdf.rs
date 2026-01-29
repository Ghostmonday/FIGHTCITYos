use std::env;
use std::path::{Path, PathBuf};
use walkdir::WalkDir;

fn main() {
    // Get home directory - try both current user and evan user
    let current_home = env::var("HOME").unwrap_or_else(|_| "/root".to_string());
    let evan_home = PathBuf::from("/home/evan");
    
    let downloads_paths = vec![
        PathBuf::from(&current_home).join("Downloads"),
        evan_home.join("Downloads"),
        PathBuf::from("/root/Downloads"),
    ];
    
    let target_filename = "proton-recovery-kit.pdf";
    
    println!("Searching for '{}'...", target_filename);
    println!("Excluding Downloads folders:");
    for path in &downloads_paths {
        println!("  - {}", path.display());
    }
    println!();
    
    let mut found_files = Vec::new();
    let mut errors = Vec::new();
    
    // Search from root directory (/)
    let root = Path::new("/");
    
    println!("Scanning filesystem (this may take a while)...");
    
    for entry in WalkDir::new(root)
        .follow_links(false)
        .into_iter()
        .filter_entry(|e| {
            // Skip common system directories that we don't need to search
            let path = e.path();
            let path_str = path.to_string_lossy();
            
            // Skip system directories that are unlikely to contain user files
            !path_str.contains("/proc") &&
            !path_str.contains("/sys") &&
            !path_str.contains("/dev") &&
            !path_str.contains("/run") &&
            !path_str.contains("/tmp") &&
            !path_str.contains("/var/cache") &&
            !path_str.contains("/var/tmp")
        })
    {
        match entry {
            Ok(entry) => {
                let path = entry.path();
                
                // Check if this is the target file
                if path.is_file() {
                    if let Some(filename) = path.file_name() {
                        if filename == target_filename {
                            // Check if it's NOT in any Downloads folder
                            let is_in_downloads = downloads_paths.iter().any(|downloads_path| {
                                path.starts_with(downloads_path)
                            });
                            
                            if !is_in_downloads {
                                found_files.push(path.to_path_buf());
                            }
                        }
                    }
                }
            }
            Err(e) => {
                // Store errors but continue searching
                errors.push(e);
            }
        }
    }
    
    println!();
    println!("Search complete!");
    println!();
    
    if found_files.is_empty() {
        println!("No other instances of '{}' found (excluding Downloads folder).", target_filename);
    } else {
        println!("Found {} instance(s) of '{}' (excluding Downloads):", found_files.len(), target_filename);
        println!();
        for (i, file) in found_files.iter().enumerate() {
            println!("{}. {}", i + 1, file.display());
            
            // Try to get file metadata
            if let Ok(metadata) = std::fs::metadata(file) {
                println!("   Size: {} bytes", metadata.len());
                if let Ok(modified) = metadata.modified() {
                    if let Ok(datetime) = modified.duration_since(std::time::UNIX_EPOCH) {
                        println!("   Modified: {} seconds since epoch", datetime.as_secs());
                    }
                }
            }
            println!();
        }
    }
    
    if !errors.is_empty() {
        eprintln!("Note: {} errors encountered during search (likely permission denied)", errors.len());
    }
}
