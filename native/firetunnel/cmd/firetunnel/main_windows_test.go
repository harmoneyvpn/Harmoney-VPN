//go:build windows

package main

import "testing"

func TestXrayDirectIPv4CIDRsReadsOnlyDirectRules(t *testing.T) {
	config := map[string]any{
		"routing": map[string]any{
			"rules": []any{
				map[string]any{"outboundTag": "proxy", "ip": []any{"8.8.8.0/24"}},
				map[string]any{"outboundTag": "direct", "ip": []any{"5.56.0.0/15", "5.56.0.0/15", "2.144.1.1/14"}},
			},
		},
	}
	got, err := xrayDirectIPv4CIDRs(config)
	if err != nil {
		t.Fatal(err)
	}
	want := []string{"2.144.0.0/14", "5.56.0.0/15"}
	if len(got) != len(want) {
		t.Fatalf("got %v, want %v", got, want)
	}
	for i := range want {
		if got[i] != want[i] {
			t.Fatalf("got %v, want %v", got, want)
		}
	}
}

func TestXrayDirectIPv4CIDRsRejectsUnsafeOrUnsupportedRanges(t *testing.T) {
	for _, cidr := range []string{"0.0.0.0/0", "10.0.0.0/7", "2001:db8::/32", "not-a-cidr"} {
		config := map[string]any{
			"routing": map[string]any{
				"rules": []any{map[string]any{"outboundTag": "direct", "ip": []any{cidr}}},
			},
		}
		if _, err := xrayDirectIPv4CIDRs(config); err == nil {
			t.Errorf("expected %q to be rejected", cidr)
		}
	}
}
