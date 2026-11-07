package serverlist

import (
	"fmt"
	"strings"

	"firetunnel/internal/provider"
)

type Candidate struct {
	Addr        string
	CountryName string
	CountryCode string
	CityName    string
	CityCode    string
}

func ConnectCandidates(countries []provider.Country) []Candidate {
	var out []Candidate
	seen := map[string]bool{}
	for _, c := range countries {
		for _, city := range c.Cities {
			for _, s := range city.Servers {
				if s.Quarantined {
					continue
				}
				for _, p := range s.Protocols {
					if strings.EqualFold(p.Name, "connect") && p.Host != "" && p.Port > 0 {
						k := fmt.Sprintf("%s:%d", p.Host, p.Port)
						if !seen[k] {
							seen[k] = true
							out = append(out, Candidate{
								Addr: k, CountryName: c.Name, CountryCode: c.Code,
								CityName: city.Name, CityCode: city.Code,
							})
						}
					}
				}
				if len(s.Protocols) == 0 && s.Hostname != "" && s.Port > 0 {
					k := fmt.Sprintf("%s:%d", s.Hostname, s.Port)
					if !seen[k] {
						seen[k] = true
						out = append(out, Candidate{Addr: k, CountryName: c.Name, CountryCode: c.Code, CityName: city.Name, CityCode: city.Code})
					}
				}
			}
		}
	}
	return out
}

func Select(countries []provider.Country, filter string) (Candidate, error) {
	all := ConnectCandidates(countries)
	if len(all) == 0 {
		return Candidate{}, fmt.Errorf("no HTTP CONNECT candidates found")
	}
	f := strings.TrimSpace(filter)
	if f == "" || strings.EqualFold(f, "REC") || strings.EqualFold(f, "recommended") {
		for _, c := range all {
			if strings.EqualFold(c.CountryCode, "REC") || strings.Contains(strings.ToLower(c.CountryName), "recomend") {
				return c, nil
			}
		}
		return all[0], nil
	}
	for _, c := range all {
		if strings.EqualFold(c.CountryCode, f) || strings.EqualFold(c.CountryName, f) || strings.EqualFold(c.CityCode, f) {
			return c, nil
		}
	}
	return Candidate{}, fmt.Errorf("no CONNECT server found for %q", filter)
}

