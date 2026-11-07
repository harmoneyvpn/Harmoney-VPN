package tunnel

import (
	"context"
	"errors"
)

var ErrNotImplemented = errors.New("tunnel transport is scheduled for phase 2")

type Dialer interface {
	DialContext(ctx context.Context, network, address string) error
}

