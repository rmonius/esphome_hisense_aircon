// ============================================================
// Gehäuse für ESP32-WROOM-32 DevKit + RS485-zu-TTL-Modul
// Nebeneinander montiert, Deckel mit 4 Schraubbossen (M3, selbstschneidend)
// ============================================================
//
// Annahmen (bei Bedarf anpassen, falls dein Board abweicht):
// - ESP32-WROOM-32 DevKit (breite 38-Pin-Version): 55 x 28 x 1.6mm
// - RS485-TTL-Modul (Automatik-Flow-Control, Schraubklemmen): 31.5 x 20mm,
//   Schraubklemmen (A/B) an einer Schmalseite, 4-Pin-Header (VCC/GND/RXD/TXD)
//   an der gegenüberliegenden Seite -> zeigt nach INNEN (interne Verkabelung
//   zum ESP32, kein Wandausschnitt noetig)
// - Beide Boards liegen auf kleinen Eck-Noppen (2mm hoch), damit geloetete
//   Pins/Anschlüsse auf der Unterseite Platz haben
// - Kabeleingang (fuer duenne Stromkabel an 5V/VIN+GND-Loetpins) an der
//   ESP32-Seite: offene Kerbe, die sich aus einem Ausschnitt in der
//   Wand-Oberkante UND einem passenden Ausschnitt in der Deckel-Unterkante
//   zusammensetzt - Kabel wird von oben eingelegt, bevor der Deckel
//   aufgeschraubt wird. Sitzt versetzt neben der USB-Aussparung (siehe unten),
//   damit sich beide Ausschnitte nicht überschneiden.
// - Zusaetzlich eine rechteckige USB-Aussparung (mittig), damit bei
//   geschlossenem Gehaeuse ueber die Micro-USB-Buchse geflasht werden kann
//
// Rendern: openscad -o gehaeuse.stl esp32_rs485_gehaeuse.scad
//          (oder in der OpenSCAD-GUI F6 -> Export als STL)
//
// Zum Drucken: 2 separate Teile (Basis + Deckel) - unten stehen zwei
// Aufrufe nebeneinander auf der Druckplatte.

// ---------------- Parameter ----------------

// Wandstärke / Bodenstärke / Deckelstärke
wall     = 2.2;
floor_h  = 2.0;
lid_h    = 2.0;

// Toleranz rund um die Platinen (pro Seite)
gap = 1.0;

// ESP32-WROOM-32 DevKit (breite Version)
esp32_l = 55;   // Länge
esp32_w = 28;   // Breite

// Kabeleingang (ESP32-Seite, linke Außenwand) - offene Kerbe an der Oberkante,
// versetzt zur Seite (nicht mittig), damit Platz fuer die USB-Aussparung bleibt
cable_d          = 5;   // ungefaehrer Kabeldurchmesser
cable_clearance  = 1;   // zusaetzliches Spiel
cable_notch_w    = cable_d + cable_clearance;  // Breite der Kerbe
cable_notch_depth= cable_d + cable_clearance;  // Tiefe der Kerbe (ab Wand-Oberkante nach unten)
cable_offset     = 5;   // Abstand der Kerben-Mitte von der Pocket-Kante (statt mittig)

// USB-Aussparung (ESP32-Seite, linke Außenwand, mittig) - fuers Flashen bei
// geschlossenem Gehaeuse, Micro-USB-Buchse muss dafuer nah an der Gehaeusewand
// liegen (Platine ggf. mit wall+gap Abstand zur Wand ausrichten)
usb_w = 9;    // Breite des USB-Ausschnitts
usb_h = 4;    // Höhe des USB-Ausschnitts
usb_z = 5;    // Unterkante des Ausschnitts über der Standfläche

// RS485-TTL-Modul
rs485_l = 31.5; // Länge (Richtung mit Schraubklemmen)
rs485_w = 20;   // Breite
term_w  = 14;   // Breite des Ausschnitts für die Schraubklemmen
term_h  = 12;   // Höhe des Ausschnitts (Klemmen stehen recht hoch)
term_z  = 2;    // Unterkante des Ausschnitts über der Standfläche

// Innenhöhe (Platz für Bauteile/Pins über und unter der Platine)
inner_h = 18;

// Abstand zwischen den beiden Platinenfächern
board_gap = 4;

// Eck-Auflagenoppen (halten die Platine leicht über dem Boden)
nub_size = 3;
nub_h    = 2;

// Lüftungsschlitze im Deckel
vent = true;
vent_slot_w = 1.6;
vent_slot_l = 14;
vent_count  = 5;

// Schraubbosse für Deckelbefestigung (M3 selbstschneidend)
screw_hole_d = 2.6;   // Bohrung für selbstschneidende M3-Schraube
boss_d       = 7;     // Außendurchmesser des Bosses
screw_head_d = 6;     // Senkung im Deckel für Schraubenkopf
screw_head_h = 2.2;

// ---------------- Abgeleitete Maße ----------------

esp32_pocket_l  = esp32_l + 2*gap;
esp32_pocket_w  = esp32_w + 2*gap;
rs485_pocket_l  = rs485_l + 2*gap;
rs485_pocket_w  = rs485_w + 2*gap;

inner_w = max(esp32_pocket_w, rs485_pocket_w);
inner_l = esp32_pocket_l + board_gap + rs485_pocket_l;

outer_l = inner_l + 2*wall;
outer_w = inner_w + 2*wall;

// Gesamthöhe = Boden + Innenraum + Deckel. Die Basis-Wände reichen bis
// (floor_h+inner_h) = (outer_h-lid_h), der Deckel setzt genau dort bündig auf.
outer_h  = floor_h + inner_h + lid_h;
wall_top = floor_h + inner_h;   // = outer_h - lid_h

boss_inset = boss_d/2 + 1.5; // Abstand der Bossmitte von den Außenkanten

$fn = 48;

// ---------------- Hilfsmodule ----------------

module nub(x, y) {
    translate([x, y, floor_h])
        cylinder(d=nub_size, h=nub_h);
}

module board_nubs(px, py, pl, pw) {
    inset = 3;
    nub(px+inset,      py+inset);
    nub(px+pl-inset,   py+inset);
    nub(px+inset,      py+pw-inset);
    nub(px+pl-inset,   py+pw-inset);
}

// ---------------- Basis (Boden + Wände) ----------------

module basis() {
    esp32_x = wall;
    esp32_y = wall + (inner_w - esp32_pocket_w)/2;
    rs485_x = wall + esp32_pocket_l + board_gap;
    rs485_y = wall + (inner_w - rs485_pocket_w)/2;

    cable_y = esp32_y + cable_offset;             // Kerbe versetzt zur Seite
    usb_y   = esp32_y + esp32_pocket_w/2;         // USB-Aussparung mittig

    difference() {
        // Außenkontur (Wände nur bis wall_top, nicht bis outer_h!)
        cube([outer_l, outer_w, wall_top]);

        // Innenraum aushöhlen (Boden bleibt stehen, oben offen für Deckel)
        translate([wall, wall, floor_h])
            cube([inner_l, inner_w, wall_top]);

        // Kabeleingang: offene Kerbe von der Wand-Oberkante nach unten
        // (linke Außenwand, ESP32-Seite, versetzt)
        translate([-1, cable_y - cable_notch_w/2, wall_top - cable_notch_depth])
            cube([wall+2, cable_notch_w, cable_notch_depth + 1]);

        // USB-Aussparung (linke Außenwand, ESP32-Seite, mittig) - fuers Flashen
        translate([-1, usb_y - usb_w/2, floor_h+usb_z])
            cube([wall+2, usb_w, usb_h]);

        // Schraubklemmen-Ausschnitt (RS485-Seite, rechte Außenwand)
        translate([outer_l-wall-1, rs485_y + (rs485_pocket_w-term_w)/2, floor_h+term_z])
            cube([wall+2, term_w, term_h]);

        // Schraubenlöcher für Deckelbosse (Bohrung geht bis oben durch den Boss)
        for (p = [[boss_inset, boss_inset],
                  [outer_l-boss_inset, boss_inset],
                  [boss_inset, outer_w-boss_inset],
                  [outer_l-boss_inset, outer_w-boss_inset]])
            translate([p[0], p[1], -1])
                cylinder(d=screw_hole_d, h=wall_top+2);
    }

    // Schraubbosse (innen an den 4 Ecken, bis zur Wand-Oberkante)
    for (p = [[boss_inset, boss_inset],
              [outer_l-boss_inset, boss_inset],
              [boss_inset, outer_w-boss_inset],
              [outer_l-boss_inset, outer_w-boss_inset]])
        difference() {
            translate([p[0], p[1], floor_h])
                cylinder(d=boss_d, h=inner_h);
            translate([p[0], p[1], floor_h-1])
                cylinder(d=screw_hole_d, h=inner_h+2);
        }

    // Auflagenoppen für die Platinen
    board_nubs(esp32_x, esp32_y, esp32_pocket_l, esp32_pocket_w);
    board_nubs(rs485_x, rs485_y, rs485_pocket_l, rs485_pocket_w);
}

// ---------------- Deckel ----------------

module deckel() {
    esp32_y = wall + (inner_w - esp32_pocket_w)/2;
    cable_y = esp32_y + cable_offset;

    difference() {
        union() {
            cube([outer_l, outer_w, lid_h]);
            // kleiner Steg innen, der in die Basis greift (Führung/Staubschutz)
            translate([wall+0.3, wall+0.3, -2])
                cube([inner_l-0.6, inner_w-0.6, 2]);
        }

        // Senklöcher für Schraubenköpfe
        for (p = [[boss_inset, boss_inset],
                  [outer_l-boss_inset, boss_inset],
                  [boss_inset, outer_w-boss_inset],
                  [outer_l-boss_inset, outer_w-boss_inset]]) {
            translate([p[0], p[1], -1])
                cylinder(d=screw_hole_d+0.4, h=lid_h+2);
            translate([p[0], p[1], lid_h-screw_head_h])
                cylinder(d=screw_head_d, h=screw_head_h+1);
        }

        // Passende Kerbe fuer den Kabeleingang (linke Kante, ueber der Basis-Kerbe)
        translate([-1, cable_y - cable_notch_w/2, -1])
            cube([wall+2, cable_notch_w, lid_h+2]);

        // Lüftungsschlitze über dem ESP32 (falls gewünscht)
        if (vent) {
            esp32_x = wall;
            for (i = [0:vent_count-1])
                translate([esp32_x + esp32_pocket_l/2 - vent_count*4/2 + i*4,
                           esp32_y + esp32_pocket_w/2 - vent_slot_l/2,
                           -1])
                    cube([vent_slot_w, vent_slot_l, lid_h+2]);
        }
    }
}

// ---------------- Ausgabe: Basis + Deckel nebeneinander ----------------

basis();

translate([0, outer_w + 10, 0])
    deckel();

// Zum Kontrollieren der Passung (Deckel auf Basis) folgende Zeilen einkommentieren
// und die zwei Zeilen oben auskommentieren:
// basis();
// translate([0,0,wall_top]) deckel();
