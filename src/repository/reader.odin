package repository

import "core:encoding/json"
import "core:fmt"
import "core:os"
import "core:strings"
import "src:log"

@(private)
REPO_CONFIG_DIR :: "data/repo"
@(private)
BASE_NAMESPACE :: "base"

@(private)
Entry :: struct {
	item: ItemDef,
}

@(private)
readRepo :: proc(repo: ^Repository) {
	scratch := context.temp_allocator
	nsCnt := 0
	cfgCnt := 0
	foundBase := false

	dirHandle, openErr := os.open(REPO_CONFIG_DIR)
	if openErr != nil {
		log.Err("(Repo) Could not open repo directory at %s!", REPO_CONFIG_DIR)
	}
	defer os.close(dirHandle)

	namespaces, readErr := os.read_directory(dirHandle, 0, scratch)
	if readErr != nil {
		log.Err("(Repo) Could not read repo directory at %s!", REPO_CONFIG_DIR)
	}

	for namespace in namespaces {
		if namespace.type != .Directory {
			log.Warn("(Repo) %s is a stray file, skipping.", namespace.fullpath)
			continue
		}

		nsDirHandle, nsOpenErr := os.open(namespace.fullpath)
		if nsOpenErr != nil {
			log.Warn(
				"(Repo) Could not open repo namespace directory at %s, skipping.",
				namespace.fullpath,
			)
			continue
		}
		defer os.close(nsDirHandle)

		files, nsReadErr := os.read_directory(nsDirHandle, 0, scratch)
		if nsReadErr != nil {
			log.Warn(
				"(Repo) Could not read repo namespace directory at %s, skipping.",
				namespace.fullpath,
			)
			continue
		}

		if namespace.name == BASE_NAMESPACE {
			foundBase = true
		}

		for file in files {
			if readFile(file.fullpath, namespace.name, repo) {
				cfgCnt += 1
			}
		}

		nsCnt += 1
	}

	if !foundBase {
		log.Err("(Repo) Did not read any file in the base namespace!")
	}

	log.Debug("(Repo) Added %d configurations to the repo across %d namespaces.", cfgCnt, nsCnt)
}

@(private)
readFile :: proc(path, namespace: string, repo: ^Repository) -> (ok: bool) {
	jsonData, readErr := os.read_entire_file(path, context.temp_allocator)

	if readErr != nil {
		log.Err("(Repo) Failed to read config file %s!", path, panic = false)
		return false
	}

	entry: Entry
	if json.unmarshal(jsonData, &entry, .MJSON, allocator(repo)) != nil {
		log.Err("(Repo) Failed to parse config file %s!", path, panic = false)
		return false
	}

	if entry.item.key != "" {
		fullKey := ""
		if strings.contains_rune(entry.item.key, ':') {
			fullKey = entry.item.key
		} else {
			fullKey = strings.concatenate({namespace, ":", entry.item.key}, allocator(repo))
		}
		Register(&repo.items, fullKey, entry.item)
	}

	return true
}
