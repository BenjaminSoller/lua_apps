-- Globale Variablen
local cellCount = 4 -- Standardwert für 4S LiPo
local minVoltage = 3.2 -- Minimalspannung pro Zelle
local maxVoltage = 4.2 -- Maximalspannung pro Zelle
local voltage = 0
local percent = 0
local dischargeCurve = {100, 90, 80, 70, 60, 50, 40, 30, 20, 10, 5, 0} -- Beispielhafte Entladekurve

-- Einstellungen
local function initForm()
    form.addRow(2)
    form.addLabel({label="Zellenanzahl (S)", width=220})
    form.addIntbox(cellCount, 2, 10, 4, 0, 1, function(value) cellCount = value end)
    
    form.addRow(2)
    form.addLabel({label="Minimale Zellenspannung", width=220})
    form.addIntbox(minVoltage, 3.0, 3.7, 3.2, 1, 0.1, function(value) minVoltage = value end)
    
    form.addRow(2)
    form.addLabel({label="Maximale Zellenspannung", width=220})
    form.addIntbox(maxVoltage, 4.0, 4.3, 4.2, 1, 0.1, function(value) maxVoltage = value end)

    form.addRow(1)
    form.addLabel({label="Die Entladekurve anpassen im Skript falls nötig.", font=FONT_BOLD})
end

-- Berechnung der Batteriespannung in Prozent
local function calculatePercentage()
    local totalMaxVoltage = cellCount * maxVoltage
    local totalMinVoltage = cellCount * minVoltage
    local totalVoltageRange = totalMaxVoltage - totalMinVoltage
    local voltageRange = voltage - totalMinVoltage
    
    percent = math.max(0, math.min(100, (voltageRange / totalVoltageRange) * 100))
    
    -- Anwenden der Entladekurve
    local curveIndex = math.floor(percent / (100 / #dischargeCurve)) + 1
    percent = dischargeCurve[curveIndex]
end

-- Zeichne Batteriesymbol mit Farben
local function drawBattery(x, y, w, h)
    local color
    if percent > 75 then
        color = lcd.RGB(0, 255, 0) -- Grün
    elseif percent > 50 then
        color = lcd.RGB(255, 255, 0) -- Gelb
    elseif percent > 25 then
        color = lcd.RGB(255, 165, 0) -- Orange
    else
        color = lcd.RGB(255, 0, 0) -- Rot
    end
    
    lcd.setColor(color)
    lcd.drawFilledRectangle(x, y, w, h * (percent / 100))
    lcd.setColor(lcd.RGB(255, 255, 255)) -- Reset auf Weiß
    lcd.drawRectangle(x, y, w, h)
end

-- Hauptanzeige auf dem Telemetrie-Bildschirm
local function loop()
    -- Telemetrie-Wert abfragen
    voltage = getValue("Volt") -- Name des Telemetrie-Sensors, ggf. anpassen
    
    -- Prozentsatz berechnen
    calculatePercentage()

    -- Batterieanzeige zeichnen
    lcd.clear()
    lcd.drawText(10, 10, "Akkustatus: " .. math.floor(percent) .. "%", FONT_MAXI)
    drawBattery(10, 40, 50, 100)
end

-- Registrierung der init und loop Funktionen
return {init=initForm, loop=loop}
