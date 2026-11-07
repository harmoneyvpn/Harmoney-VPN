//go:build !windows

package auth

import "os"

func isRoot() bool { return os.Geteuid() == 0 }
