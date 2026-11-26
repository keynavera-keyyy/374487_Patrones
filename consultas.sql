-- Consultas SQL - Informe de consultoría (distribuidora de abarrotes)
-- Claves de estado: 02 = BC, 03 = BCS, 25 = Sinaloa, 26 = Sonora

-- Consulta 1: negocios y comercio al por menor por municipio (hallazgos 1 y 2)
SELECT entidad, municipio,
       COUNT(*) AS total_negocios,
       COUNT(*) FILTER (WHERE codigo_act / 10000 = 46) AS comercio_menor
FROM denue_inegi_oficial
WHERE cve_ent IN (3, 25, 26)
  AND (municipio ILIKE '%hermosillo%' OR municipio ILIKE '%cajeme%'
    OR municipio ILIKE '%culiac%' OR municipio ILIKE '%mazatl%'
    OR municipio ILIKE '%la paz%' OR municipio ILIKE '%los cabos%')
GROUP BY entidad, municipio
ORDER BY comercio_menor DESC;

-- Consulta 2: abarrotes y minisupers (clientes directos)
SELECT municipio,
       COUNT(*) FILTER (WHERE codigo_act = 461110) AS abarrotes,
       COUNT(*) FILTER (WHERE codigo_act = 462112) AS minisupers
FROM denue_inegi_oficial
WHERE cve_ent IN (3, 25, 26)
GROUP BY municipio
ORDER BY abarrotes DESC
LIMIT 10;

-- Consulta 3: tamaño de las tiendas de abarrotes (hallazgo 5)
SELECT municipio, per_ocu, COUNT(*) AS tiendas
FROM denue_inegi_oficial
WHERE cve_ent IN (3, 25, 26) AND codigo_act = 461110
GROUP BY municipio, per_ocu
ORDER BY municipio, tiendas DESC;

-- Consulta 4: precio promedio de gasolina y diésel por estado (hallazgo 3)
SELECT cve_ent, tipo, ROUND(AVG(precio), 2) AS precio_promedio
FROM precio_gasolina_estado
WHERE cve_ent IN ('02', '03', '25', '26')
  AND fecha >= '2026-01-01'
GROUP BY cve_ent, tipo
ORDER BY tipo, precio_promedio;

-- Consulta 5: noticias de cierres o violencia por estado (hallazgo 4)
SELECT CASE WHEN tsv @@ to_tsquery('spanish', 'sinaloa | culiacan') THEN 'Sinaloa'
            WHEN tsv @@ to_tsquery('spanish', 'sonora | hermosillo') THEN 'Sonora'
            ELSE 'BCS' END AS estado,
       COUNT(*) AS noticias,
       ROUND(AVG(sentimiento), 3) AS sentimiento_prom
FROM noticia
WHERE tsv @@ to_tsquery('spanish', '(cierre | violencia | inseguridad) & (sinaloa | culiacan | sonora | hermosillo | "baja california sur")')
GROUP BY 1;

-- Consulta 6: problemas de calidad de datos (sección 7)
SELECT COUNT(*) - COUNT(DISTINCT clee) AS duplicados,
       COUNT(*) FILTER (WHERE per_ocu IS NULL) AS sin_personal,
       COUNT(*) FILTER (WHERE latitud IS NULL) AS sin_ubicacion
FROM denue_inegi_oficial
WHERE cve_ent IN (3, 25, 26);
