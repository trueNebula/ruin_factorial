package repository

import "core:encoding/json"
import "core:fmt"
import "core:mem"
import "core:os"
import "core:sort"
import "core:strings"
import "src:log"

@(private)
REPO_CONFIG_DIR :: "data/repo"
@(private)
BASE_NAMESPACE :: "base"

@(private)
Entry :: struct {
	item:  ItemDef,
	block: BlockDef,
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

		subdirs, sdReadErr := os.read_directory(nsDirHandle, 0, scratch)
		if sdReadErr != nil {
			log.Warn(
				"(Repo) Could not read repo subdirectory at %s, skipping.",
				namespace.fullpath,
			)
			continue
		}

		for subdir in subdirs {
			subdirHandle, subdirOpenErr := os.open(subdir.fullpath)
			if subdirOpenErr != nil {
				log.Warn(
					"(Repo) Could not open repo subdirectory at %s, skipping.",
					namespace.fullpath,
				)
				continue
			}
			defer os.close(subdirHandle)

			files, nsReadErr := os.read_directory(subdirHandle, 0, scratch)
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

			sort.quick_sort_proc(files, proc(a: os.File_Info, b: os.File_Info) -> int {
				return sort.compare_strings(a.name, b.name)
			})

			for file in files {
				if readFile(file.fullpath, namespace.name, repo) {
					cfgCnt += 1
				}
			}

			nsCnt += 1
		}
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
		fullKey := getFullKey(entry.item.key, namespace, allocator(repo))
		Register(&repo.items, fullKey, entry.item)
	}

	if entry.block.key != "" {
		fullKey := getFullKey(entry.block.key, namespace, allocator(repo))
		Register(&repo.blocks, fullKey, entry.block)
	}

	return true
}

@(private)
getFullKey :: proc(key: string, namespace: string, allocator: mem.Allocator) -> string {
	if strings.contains_rune(key, ':') {
		return key
	}
	return strings.concatenate({namespace, ":", key}, allocator)
}
