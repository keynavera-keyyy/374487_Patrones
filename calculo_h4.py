km = {"Hermosillo": 690, "Culiacan": 1553}
for ciudad, d in km.items():
  costo = d / 3.5 * 27
  print(ciudad, round(costo))
  
