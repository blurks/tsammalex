from __future__ import print_function, unicode_literals
import json
from itertools import groupby

from clld.util import slug, nfilter

from tsammalex.models import Biome, Ecoregion


def update_species_data(species, d):
    for vn in d.get('eol', {}).get('vernacularNames', []):
        if vn['language'] == 'en' and vn['eol_preferred']:
            if slug(vn['vernacularName']) != slug(species.description):
                #print(species.description, '-->', vn['vernacularName'])
                species.description = vn['vernacularName']
            break

    for an in d.get('eol', {}).get('ancestors', []):
        if not an.get('taxonRank'):
            continue
        for tr in ['family', 'order', 'genus']:
            if tr == an['taxonRank']:
                curr = getattr(species, tr)
                if curr != an['scientificName']:
                    #print(tr, ':', curr, '-->', an['scientificName'])
                    setattr(species, tr, an['scientificName'])

    for k, v in d.get('wikipedia', {}).items():
        for tr in ['family', 'order', 'genus']:
            if tr == k:
                curr = getattr(species, tr)
                if curr != v:
                    #print(tr, ':', curr, '-->', v)
                    setattr(species, tr, v)

    if species.eol_id and not d.get('eol'):
        print('eol_id:', species.eol_id, '-->', None)
        species.eol_id = None


def get_center(arr):
    return reduce(
        lambda x, y: [x[0] + y[0] / len(arr), x[1] + y[1] / len(arr)], arr, [0.0, 0.0])


def load_ecoregions(args, data):
    with open(args.data_file('wwf', 'simplified.json')) as fp:
        ecoregions = json.load(fp)['features']

    biome_map = {
        1: ('Tropical & Subtropical Moist Broadleaf Forests', '008001'),
        2: ('Tropical & Subtropical Dry Broadleaf Forests', '557715'),
        3: ('Tropical & Subtropical Coniferous Forests', ''),
        4: ('Temperate Broadleaf & Mixed Forests', ''),
        5: ('Temperate Conifer Forests', ''),
        6: ('Boreal Forests/Taiga', ''),
        7: ('Tropical & Subtropical Grasslands, Savannas & Shrublands', '98ff66'),
        8: ('Temperate Grasslands, Savannas & Shrublands', ''),
        9: ('Flooded Grasslands & Savannas', '0265fe'),
        10: ('Montane Grasslands & Shrublands', 'cdffcc'),
        11: ('Tundra', ''),
        12: ('Mediterranean Forests, Woodlands & Scrub', 'cc9900'),
        13: ('Deserts & Xeric Shrublands', 'feff99'),
        14: ('Mangroves', '870083'),
    }

    for eco_code, features in groupby(
            sorted(ecoregions, key=lambda e: e['properties']['eco_code']),
            key=lambda e: e['properties']['eco_code']):
        features = list(features)
        props = features[0]['properties']
        if int(props['BIOME']) not in biome_map:
            continue
        biome = data['Biome'].get(props['BIOME'])
        if not biome:
            name, color = biome_map[int(props['BIOME'])]
            biome = data.add(
                Biome, props['BIOME'],
                id=str(int(props['BIOME'])),
                name=name,
                description=color or 'ffffff')
        centroid = (None, None)
        f = sorted(features, key=lambda _f: _f['properties']['AREA'])[-1]
        if f['geometry']:
            coords = f['geometry']['coordinates'][0]
            if f['geometry']['type'] == 'MultiPolygon':
                coords = coords[0]
            centroid = get_center(coords)

        polygons = nfilter([_f['geometry'] for _f in features])
        data.add(
            Ecoregion, eco_code,
            id=eco_code,
            name=props['ECO_NAME'],
            description=props['G200_REGIO'],
            latitude=centroid[1],
            longitude=centroid[0],
            biome=biome,
            area=props['area_km2'],
            gbl_stat=Ecoregion.gbl_stat_map[int(props['GBL_STAT'])],
            realm=Ecoregion.realm_map[props['REALM']],
            jsondata=dict(polygons=polygons))