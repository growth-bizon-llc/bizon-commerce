# frozen_string_literal: true

puts "=" * 60
puts "  Seeding Samdalth Gold - Joyería Premium"
puts "=" * 60
puts ""

# =============================================================================
# STORE
# =============================================================================
store = Store.find_or_create_by!(slug: 'samdalth-gold') do |s|
  s.name = 'Samdalth Gold'
  s.custom_domain = 'samdalthgold.localhost'
  s.subdomain = 'samdalth'
  s.description = 'Joyería premium artesanal. Piezas exclusivas en oro, plata y gemas preciosas.'
  s.currency = 'USD'
  s.locale = 'es'
  s.settings = {
    theme: 'luxury',
    logo_url: nil,
    primary_color: '#C9A84C',
    secondary_color: '#1A1A2E',
    accent_color: '#E8D5B7'
  }
end
puts "  Store: #{store.name} (#{store.slug})"

Current.store = store

# =============================================================================
# USERS (Staff)
# =============================================================================
owner = User.find_or_create_by!(email: 'samuel@samdalthgold.com') do |u|
  u.store = store
  u.first_name = 'Samuel'
  u.last_name = 'Dalth'
  u.password = 'password123'
  u.password_confirmation = 'password123'
  u.role = :owner
  u.jti = SecureRandom.uuid
end

admin = User.find_or_create_by!(email: 'carolina@samdalthgold.com') do |u|
  u.store = store
  u.first_name = 'Carolina'
  u.last_name = 'Mejía'
  u.password = 'password123'
  u.password_confirmation = 'password123'
  u.role = :admin
  u.jti = SecureRandom.uuid
end

staff = User.find_or_create_by!(email: 'andrea@samdalthgold.com') do |u|
  u.store = store
  u.first_name = 'Andrea'
  u.last_name = 'Ríos'
  u.password = 'password123'
  u.password_confirmation = 'password123'
  u.role = :staff
  u.jti = SecureRandom.uuid
end

puts "  Users: #{owner.email} (owner), #{admin.email} (admin), #{staff.email} (staff)"

# =============================================================================
# CATEGORIES
# =============================================================================
categories_data = [
  {
    name: 'Anillos',
    description: 'Anillos de compromiso, alianzas y anillos de diseñador en oro y plata con gemas preciosas.',
    subcategories: [
      { name: 'Anillos de Compromiso', description: 'Anillos de compromiso con diamantes y gemas preciosas.' },
      { name: 'Alianzas de Boda', description: 'Alianzas clásicas y modernas para el día más especial.' },
      { name: 'Anillos de Diseñador', description: 'Piezas únicas de colección con diseños exclusivos.' }
    ]
  },
  {
    name: 'Aretes',
    description: 'Aretes y pendientes artesanales. Desde studs clásicos hasta diseños statement.',
    subcategories: [
      { name: 'Studs', description: 'Aretes pequeños y elegantes para uso diario.' },
      { name: 'Aretes Colgantes', description: 'Pendientes largos y elegantes para ocasiones especiales.' },
      { name: 'Argollas', description: 'Argollas clásicas en diferentes tamaños y materiales.' }
    ]
  },
  {
    name: 'Pulseras y Manillas',
    description: 'Pulseras, manillas y brazaletes en oro, plata y con piedras preciosas.',
    subcategories: [
      { name: 'Pulseras de Cadena', description: 'Pulseras delicadas de cadena en oro y plata.' },
      { name: 'Brazaletes Rígidos', description: 'Brazaletes sólidos con diseños contemporáneos.' },
      { name: 'Manillas con Gemas', description: 'Manillas decoradas con piedras preciosas y semi-preciosas.' }
    ]
  },
  {
    name: 'Collares',
    description: 'Collares y gargantillas premium. Cadenas finas, colgantes y piezas statement.',
    subcategories: [
      { name: 'Gargantillas', description: 'Gargantillas ceñidas al cuello con diseños modernos.' },
      { name: 'Colgantes', description: 'Collares con colgantes de gemas y diseños artesanales.' },
      { name: 'Collares Largos', description: 'Collares largos para looks sofisticados.' }
    ]
  },
  {
    name: 'Cadenas',
    description: 'Cadenas en oro 18k, oro rosa y plata 925. Diferentes grosores y estilos.',
    subcategories: [
      { name: 'Cadenas Finas', description: 'Cadenas delicadas perfectas para colgantes.' },
      { name: 'Cadenas Gruesas', description: 'Cadenas bold para un look statement.' }
    ]
  },
  {
    name: 'Gemas y Piedras',
    description: 'Gemas sueltas certificadas. Diamantes, esmeraldas, rubíes y zafiros.',
    subcategories: [
      { name: 'Diamantes', description: 'Diamantes certificados en varios cortes y quilates.' },
      { name: 'Esmeraldas', description: 'Esmeraldas colombianas de alta calidad.' },
      { name: 'Piedras Semi-preciosas', description: 'Amatistas, topacios, aguamarinas y más.' }
    ]
  },
  {
    name: 'Sets y Conjuntos',
    description: 'Conjuntos coordinados de joyería. El regalo perfecto.',
    subcategories: []
  }
]

all_categories = {}
categories_data.each_with_index do |cat_data, i|
  parent = Category.find_or_create_by!(name: cat_data[:name], store: store) do |c|
    c.description = cat_data[:description]
    c.position = i
    c.active = true
  end
  all_categories[cat_data[:name]] = parent

  cat_data[:subcategories].each_with_index do |sub_data, si|
    sub = Category.find_or_create_by!(name: sub_data[:name], store: store, parent: parent) do |c|
      c.description = sub_data[:description]
      c.position = si
      c.active = true
    end
    all_categories[sub_data[:name]] = sub
  end
end

puts "  Categories: #{categories_data.size} principales, #{categories_data.sum { |c| c[:subcategories].size }} subcategorías"

# =============================================================================
# PRODUCTS - 52 productos de joyería realistas
# =============================================================================
products_data = [
  # --- ANILLOS (12) ---
  {
    name: 'Anillo Solitario Eterno',
    category: 'Anillos de Compromiso',
    description: 'Anillo solitario con diamante central de 0.5 quilates, engaste de 6 garras en oro blanco 18k. Certificado GIA. La pieza perfecta para sellar un compromiso eterno.',
    short_description: 'Solitario con diamante 0.5ct en oro blanco 18k',
    base_price_cents: 125_000, compare_at_price_cents: 149_000,
    sku: 'AN-SOL-001', featured: true, status: 'active',
    attributes: { piedra: 'Diamante', quilates: '0.5ct', certificado: 'GIA' }
  },
  {
    name: 'Anillo Halo de Esmeralda',
    category: 'Anillos de Compromiso',
    description: 'Impresionante anillo con esmeralda colombiana central de 1.2ct rodeada por un halo de micro-pavé de diamantes. Montado en oro amarillo 18k.',
    short_description: 'Esmeralda colombiana 1.2ct con halo de diamantes',
    base_price_cents: 285_000, compare_at_price_cents: nil,
    sku: 'AN-HAL-002', featured: true, status: 'active',
    attributes: { piedra: 'Esmeralda', quilates: '1.2ct', origen: 'Colombia' }
  },
  {
    name: 'Alianza Clásica Lisa',
    category: 'Alianzas de Boda',
    description: 'Alianza de boda clásica con acabado pulido espejo. Perfil comfort-fit para uso diario. Disponible en oro amarillo, blanco y rosa.',
    short_description: 'Alianza clásica comfort-fit en oro 18k',
    base_price_cents: 45_000, compare_at_price_cents: 52_000,
    sku: 'AN-ALI-003', featured: false, status: 'active',
    attributes: { ancho: '4mm', acabado: 'Pulido espejo' }
  },
  {
    name: 'Alianza Pavé de Diamantes',
    category: 'Alianzas de Boda',
    description: 'Alianza media eternidad con diamantes en pavé alrededor de toda la banda. 0.75ct total en diamantes VS1. Oro blanco 18k.',
    short_description: 'Media eternidad con diamantes pavé 0.75ct',
    base_price_cents: 89_000, compare_at_price_cents: nil,
    sku: 'AN-APD-004', featured: false, status: 'active',
    attributes: { piedra: 'Diamante', quilates: '0.75ct total', claridad: 'VS1' }
  },
  {
    name: 'Anillo Cocktail Rubí Imperial',
    category: 'Anillos de Diseñador',
    description: 'Anillo cocktail con rubí birmano de 2.5ct talla cojín, flanqueado por triángulos de diamantes. Una pieza de museo.',
    short_description: 'Rubí birmano 2.5ct con diamantes laterales',
    base_price_cents: 450_000, compare_at_price_cents: nil,
    sku: 'AN-CKT-005', featured: true, status: 'active',
    attributes: { piedra: 'Rubí', quilates: '2.5ct', origen: 'Birmania' }
  },
  {
    name: 'Anillo Serpiente Oro Rosa',
    category: 'Anillos de Diseñador',
    description: 'Anillo wrap en forma de serpiente con ojos de esmeralda y cuerpo texturizado. Oro rosa 18k con acabado satinado.',
    short_description: 'Diseño serpiente en oro rosa con esmeraldas',
    base_price_cents: 78_000, compare_at_price_cents: 95_000,
    sku: 'AN-SRP-006', featured: false, status: 'active',
    attributes: { diseño: 'Serpiente', piedra: 'Esmeralda (ojos)' }
  },
  {
    name: 'Anillo Tres Piedras Zafiro',
    category: 'Anillos de Compromiso',
    description: 'Anillo tres piedras con zafiro azul ceilán central de 1.5ct flanqueado por dos diamantes de 0.3ct cada uno. Platino 950.',
    short_description: 'Zafiro ceilán 1.5ct con diamantes en platino',
    base_price_cents: 320_000, compare_at_price_cents: nil,
    sku: 'AN-TRP-007', featured: true, status: 'active',
    attributes: { piedra: 'Zafiro Azul', quilates: '1.5ct', metal: 'Platino 950' }
  },
  {
    name: 'Anillo Apilable Minimalista',
    category: 'Anillos de Diseñador',
    description: 'Anillo fino apilable con pequeño diamante de 0.1ct. Perfecto para combinar y apilar con otros anillos. Oro amarillo 14k.',
    short_description: 'Anillo fino apilable con diamante 0.1ct',
    base_price_cents: 22_000, compare_at_price_cents: nil,
    sku: 'AN-APL-008', featured: false, status: 'active',
    attributes: { piedra: 'Diamante', quilates: '0.1ct', metal: 'Oro 14k' }
  },
  {
    name: 'Sello Caballero Ónix',
    category: 'Anillos de Diseñador',
    description: 'Anillo sello para caballero con ónix negro pulido y detalles grabados laterales. Oro amarillo 18k con acabado antiguo.',
    short_description: 'Sello masculino con ónix negro en oro 18k',
    base_price_cents: 65_000, compare_at_price_cents: 78_000,
    sku: 'AN-SEL-009', featured: false, status: 'active',
    attributes: { piedra: 'Ónix Negro', estilo: 'Masculino' }
  },
  {
    name: 'Anillo Infinito Diamantes',
    category: 'Alianzas de Boda',
    description: 'Diseño infinito entrelazado con líneas de diamantes micro-pavé. Simbolismo eterno en oro blanco 18k. 0.45ct total.',
    short_description: 'Diseño infinito con diamantes micro-pavé',
    base_price_cents: 72_000, compare_at_price_cents: nil,
    sku: 'AN-INF-010', featured: false, status: 'active',
    attributes: { piedra: 'Diamante', quilates: '0.45ct', diseño: 'Infinito' }
  },
  {
    name: 'Anillo Art Déco Aguamarina',
    category: 'Anillos de Diseñador',
    description: 'Inspirado en los años 20, este anillo Art Déco presenta una aguamarina talla esmeralda de 3ct con detalles geométricos en milgrain.',
    short_description: 'Estilo Art Déco con aguamarina 3ct',
    base_price_cents: 95_000, compare_at_price_cents: 115_000,
    sku: 'AN-ART-011', featured: false, status: 'draft',
    attributes: { piedra: 'Aguamarina', quilates: '3ct', estilo: 'Art Déco' }
  },
  {
    name: 'Anillo Eternidad Completa',
    category: 'Alianzas de Boda',
    description: 'Anillo eternidad completa con diamantes redondos alrededor de toda la circunferencia. 2ct total en diamantes F/VS2. Platino.',
    short_description: 'Eternidad completa 2ct diamantes en platino',
    base_price_cents: 380_000, compare_at_price_cents: nil,
    sku: 'AN-ETC-012', featured: false, status: 'active',
    attributes: { piedra: 'Diamante', quilates: '2ct total', color: 'F', claridad: 'VS2' }
  },

  # --- ARETES (10) ---
  {
    name: 'Studs Diamante Clásicos',
    category: 'Studs',
    description: 'Par de studs con diamantes redondos de 0.5ct cada uno (1ct total). Engaste de 4 garras en oro blanco 18k. Cierre de presión seguro.',
    short_description: 'Studs diamante 1ct total en oro blanco',
    base_price_cents: 195_000, compare_at_price_cents: 220_000,
    sku: 'AR-STD-001', featured: true, status: 'active',
    attributes: { piedra: 'Diamante', quilates: '1ct total (0.5ct c/u)' }
  },
  {
    name: 'Studs Perla Akoya',
    category: 'Studs',
    description: 'Elegantes studs con perlas Akoya de 7-7.5mm de lustre excepcional. Monturas en oro amarillo 18k con cierre omega.',
    short_description: 'Perlas Akoya 7mm en oro amarillo 18k',
    base_price_cents: 48_000, compare_at_price_cents: nil,
    sku: 'AR-PRL-002', featured: false, status: 'active',
    attributes: { piedra: 'Perla Akoya', tamaño: '7-7.5mm' }
  },
  {
    name: 'Aretes Chandelier Esmeralda',
    category: 'Aretes Colgantes',
    description: 'Aretes chandelier con cascada de esmeraldas y diamantes. 8 esmeraldas totalizing 3.2ct y 24 diamantes. Oro blanco 18k. Largo: 5.5cm.',
    short_description: 'Chandelier con esmeraldas 3.2ct y diamantes',
    base_price_cents: 420_000, compare_at_price_cents: nil,
    sku: 'AR-CHD-003', featured: true, status: 'active',
    attributes: { piedra: 'Esmeralda + Diamante', largo: '5.5cm' }
  },
  {
    name: 'Argollas Huggies Oro',
    category: 'Argollas',
    description: 'Argollas huggie de 12mm con cierre de click seguro. Oro amarillo 18k con superficie lisa pulida. Perfectas para uso diario.',
    short_description: 'Huggies 12mm en oro amarillo 18k',
    base_price_cents: 32_000, compare_at_price_cents: 38_000,
    sku: 'AR-HUG-004', featured: false, status: 'active',
    attributes: { diámetro: '12mm', cierre: 'Click' }
  },
  {
    name: 'Aretes Gota de Rubí',
    category: 'Aretes Colgantes',
    description: 'Aretes colgantes con rubíes talla pera de 1.8ct cada uno suspendidos de un stud de diamante. Movimiento elegante. Oro rosa 18k.',
    short_description: 'Gotas de rubí 3.6ct total con diamantes',
    base_price_cents: 265_000, compare_at_price_cents: nil,
    sku: 'AR-GOT-005', featured: false, status: 'active',
    attributes: { piedra: 'Rubí', quilates: '3.6ct total' }
  },
  {
    name: 'Argollas Criollas Grandes',
    category: 'Argollas',
    description: 'Argollas criollas de 35mm con tubo hueco ligero. Acabado brillante espejo. Oro amarillo 18k. Elegancia atemporal.',
    short_description: 'Criollas 35mm en oro amarillo 18k',
    base_price_cents: 55_000, compare_at_price_cents: nil,
    sku: 'AR-CRI-006', featured: false, status: 'active',
    attributes: { diámetro: '35mm', peso: 'Ligero (tubo hueco)' }
  },
  {
    name: 'Studs Flor de Zafiro',
    category: 'Studs',
    description: 'Studs en forma de flor con zafiro central rodeado por pétalos de diamantes. Diseño delicado y femenino. Oro blanco 18k.',
    short_description: 'Flor de zafiro con pétalos de diamante',
    base_price_cents: 78_000, compare_at_price_cents: 89_000,
    sku: 'AR-FLR-007', featured: false, status: 'active',
    attributes: { piedra: 'Zafiro + Diamante', diseño: 'Flor' }
  },
  {
    name: 'Ear Cuff Serpiente',
    category: 'Aretes Colgantes',
    description: 'Ear cuff sin perforación con diseño de serpiente que abraza la oreja. Ojos de esmeralda. Oro rosa 18k. Vendido por unidad.',
    short_description: 'Ear cuff serpiente en oro rosa (unidad)',
    base_price_cents: 42_000, compare_at_price_cents: nil,
    sku: 'AR-ECF-008', featured: false, status: 'active',
    attributes: { diseño: 'Serpiente ear cuff', venta: 'Por unidad' }
  },
  {
    name: 'Aretes Geométricos Art Déco',
    category: 'Aretes Colgantes',
    description: 'Aretes de inspiración Art Déco con formas geométricas escalonadas. Ónix, diamantes y oro blanco. Largo: 4cm.',
    short_description: 'Diseño geométrico Art Déco con ónix y diamantes',
    base_price_cents: 115_000, compare_at_price_cents: nil,
    sku: 'AR-GEO-009', featured: false, status: 'draft',
    attributes: { piedra: 'Ónix + Diamante', estilo: 'Art Déco', largo: '4cm' }
  },
  {
    name: 'Studs Punto de Luz',
    category: 'Studs',
    description: 'Studs minimalistas con diamante solitario de 0.15ct engaste invisible bisel. El brillo perfecto para cada día. Oro amarillo 14k.',
    short_description: 'Punto de luz diamante 0.15ct en oro 14k',
    base_price_cents: 18_500, compare_at_price_cents: 22_000,
    sku: 'AR-PDL-010', featured: false, status: 'active',
    attributes: { piedra: 'Diamante', quilates: '0.15ct', engaste: 'Bisel' }
  },

  # --- PULSERAS Y MANILLAS (8) ---
  {
    name: 'Pulsera Tennis Diamantes',
    category: 'Pulseras de Cadena',
    description: 'Pulsera tennis clásica con 45 diamantes redondos totalizing 5ct. Engaste de 4 garras continuo. Oro blanco 18k con cierre de seguridad doble.',
    short_description: 'Tennis 5ct diamantes en oro blanco 18k',
    base_price_cents: 650_000, compare_at_price_cents: nil,
    sku: 'PU-TEN-001', featured: true, status: 'active',
    attributes: { piedra: 'Diamante', quilates: '5ct total', piezas: '45 diamantes' }
  },
  {
    name: 'Brazalete Rígido Clásico',
    category: 'Brazaletes Rígidos',
    description: 'Brazalete rígido ovalado con bisagra lateral y cierre de seguridad. Superficie lisa con borde biselado. Oro amarillo 18k.',
    short_description: 'Brazalete rígido liso en oro amarillo 18k',
    base_price_cents: 95_000, compare_at_price_cents: 110_000,
    sku: 'PU-BRA-002', featured: false, status: 'active',
    attributes: { tipo: 'Rígido con bisagra', acabado: 'Liso biselado' }
  },
  {
    name: 'Manilla Esmeraldas y Diamantes',
    category: 'Manillas con Gemas',
    description: 'Manilla flexible con alternancia de esmeraldas talla óvalo y clusters de diamantes. 12 esmeraldas (4.8ct) y 36 diamantes (1.8ct). Oro blanco 18k.',
    short_description: 'Esmeraldas 4.8ct con diamantes 1.8ct',
    base_price_cents: 520_000, compare_at_price_cents: nil,
    sku: 'PU-MED-003', featured: true, status: 'active',
    attributes: { piedra: 'Esmeralda + Diamante', quilates_esmeralda: '4.8ct', quilates_diamante: '1.8ct' }
  },
  {
    name: 'Pulsera Cadena Eslabones',
    category: 'Pulseras de Cadena',
    description: 'Pulsera de eslabones medianos tipo cable con cierre de resorte. Oro amarillo 18k. Peso: 12g. Largo: 18cm.',
    short_description: 'Eslabones cable en oro amarillo 18k',
    base_price_cents: 68_000, compare_at_price_cents: nil,
    sku: 'PU-ESL-004', featured: false, status: 'active',
    attributes: { tipo: 'Cable', peso: '12g', largo: '18cm' }
  },
  {
    name: 'Brazalete Clavo de Oro Rosa',
    category: 'Brazaletes Rígidos',
    description: 'Icónico brazalete inspirado en un clavo, envolviendo la muñeca con elegancia industrial. Oro rosa 18k con puntas de diamante.',
    short_description: 'Diseño clavo en oro rosa con diamantes',
    base_price_cents: 135_000, compare_at_price_cents: nil,
    sku: 'PU-CLV-005', featured: false, status: 'active',
    attributes: { diseño: 'Clavo', piedra: 'Diamante en puntas' }
  },
  {
    name: 'Pulsera Charm Personalizable',
    category: 'Pulseras de Cadena',
    description: 'Pulsera de cadena rolo con 3 charms incluidos: corazón, estrella y inicial. Posibilidad de agregar más charms. Plata 925 bañada en oro.',
    short_description: 'Cadena rolo con 3 charms en plata/oro',
    base_price_cents: 28_000, compare_at_price_cents: 35_000,
    sku: 'PU-CHR-006', featured: false, status: 'active',
    attributes: { charms_incluidos: 3, material: 'Plata 925 baño oro' }
  },
  {
    name: 'Manilla Riviera Zafiros',
    category: 'Manillas con Gemas',
    description: 'Manilla estilo riviera graduada con zafiros azules de tamaño creciente hacia el centro. 18 zafiros (6.5ct total). Oro blanco 18k.',
    short_description: 'Riviera graduada de zafiros 6.5ct',
    base_price_cents: 385_000, compare_at_price_cents: nil,
    sku: 'PU-RIV-007', featured: false, status: 'active',
    attributes: { piedra: 'Zafiro Azul', quilates: '6.5ct total', piezas: '18 zafiros' }
  },
  {
    name: 'Pulsera Perlas Tahití',
    category: 'Manillas con Gemas',
    description: 'Pulsera de perlas negras de Tahití de 9-10mm con broche de oro blanco y diamante. 19 perlas con lustre excepcional.',
    short_description: 'Perlas negras Tahití 9-10mm con broche diamante',
    base_price_cents: 175_000, compare_at_price_cents: 195_000,
    sku: 'PU-PTH-008', featured: false, status: 'active',
    attributes: { piedra: 'Perla Tahití', tamaño: '9-10mm', piezas: '19 perlas' }
  },

  # --- COLLARES (8) ---
  {
    name: 'Gargantilla Choker Diamantes',
    category: 'Gargantillas',
    description: 'Gargantilla rígida con frente de diamantes pavé. 2.5ct en diamantes F/VS1. Oro blanco 18k. Cierre invisible posterior.',
    short_description: 'Choker pavé 2.5ct diamantes en oro blanco',
    base_price_cents: 345_000, compare_at_price_cents: nil,
    sku: 'CO-CHK-001', featured: true, status: 'active',
    attributes: { piedra: 'Diamante', quilates: '2.5ct', color: 'F' }
  },
  {
    name: 'Colgante Lágrima Esmeralda',
    category: 'Colgantes',
    description: 'Colgante con esmeralda colombiana talla pera de 2.1ct suspendida de un bail de diamantes. Cadena veneciana de 45cm incluida. Oro amarillo 18k.',
    short_description: 'Esmeralda pera 2.1ct con cadena veneciana',
    base_price_cents: 275_000, compare_at_price_cents: nil,
    sku: 'CO-LAG-002', featured: true, status: 'active',
    attributes: { piedra: 'Esmeralda', quilates: '2.1ct', cadena: '45cm veneciana' }
  },
  {
    name: 'Collar Perlas South Sea',
    category: 'Collares Largos',
    description: 'Collar de perlas South Sea doradas de 11-13mm graduadas. 35 perlas seleccionadas por color y lustre uniforme. Broche oro 18k con diamante.',
    short_description: 'South Sea doradas 11-13mm, 35 perlas',
    base_price_cents: 890_000, compare_at_price_cents: nil,
    sku: 'CO-PSS-003', featured: true, status: 'active',
    attributes: { piedra: 'Perla South Sea', tamaño: '11-13mm', color: 'Dorado' }
  },
  {
    name: 'Colgante Cruz Diamantes',
    category: 'Colgantes',
    description: 'Cruz delicada con 11 diamantes redondos en pavé. 0.35ct total. Cadena rolo fina de 42cm. Oro rosa 18k.',
    short_description: 'Cruz con diamantes 0.35ct en oro rosa',
    base_price_cents: 52_000, compare_at_price_cents: 62_000,
    sku: 'CO-CRZ-004', featured: false, status: 'active',
    attributes: { piedra: 'Diamante', quilates: '0.35ct', símbolo: 'Cruz' }
  },
  {
    name: 'Gargantilla Luna Creciente',
    category: 'Gargantillas',
    description: 'Gargantilla con luna creciente pavé de diamantes y estrella colgante. Diseño celestial contemporáneo. Oro amarillo 18k. Largo ajustable 35-40cm.',
    short_description: 'Luna y estrella con diamantes en oro 18k',
    base_price_cents: 68_000, compare_at_price_cents: nil,
    sku: 'CO-LUN-005', featured: false, status: 'active',
    attributes: { diseño: 'Luna + Estrella', largo: '35-40cm ajustable' }
  },
  {
    name: 'Collar Cadena Figaro',
    category: 'Collares Largos',
    description: 'Collar largo cadena Figaro de 60cm. Eslabones alternados 3+1. Oro amarillo 18k macizo. Peso: 28g. Pieza unisex.',
    short_description: 'Cadena Figaro 60cm oro 18k macizo',
    base_price_cents: 185_000, compare_at_price_cents: nil,
    sku: 'CO-FIG-006', featured: false, status: 'active',
    attributes: { tipo: 'Figaro 3+1', largo: '60cm', peso: '28g' }
  },
  {
    name: 'Colgante Corazón Rubí',
    category: 'Colgantes',
    description: 'Colgante corazón con rubí talla corazón de 1.2ct rodeado por micro-pavé de diamantes. Cadena cable 40cm. Oro blanco 18k.',
    short_description: 'Corazón rubí 1.2ct con halo diamantes',
    base_price_cents: 145_000, compare_at_price_cents: nil,
    sku: 'CO-COR-007', featured: false, status: 'active',
    attributes: { piedra: 'Rubí', quilates: '1.2ct', talla: 'Corazón' }
  },
  {
    name: 'Collar Layering Triple',
    category: 'Gargantillas',
    description: 'Set de 3 collares para layering: cadena sencilla 38cm, colgante punto de luz 42cm, y cadena con charm 48cm. Oro amarillo 14k.',
    short_description: 'Triple layering set en oro 14k',
    base_price_cents: 58_000, compare_at_price_cents: 72_000,
    sku: 'CO-LAY-008', featured: false, status: 'active',
    attributes: { piezas: '3 collares', largos: '38/42/48cm' }
  },

  # --- CADENAS (5) ---
  {
    name: 'Cadena Veneciana Fina',
    category: 'Cadenas Finas',
    description: 'Cadena veneciana (box chain) de 1mm de grosor. Largo: 45cm con extensor de 5cm. Oro amarillo 18k. Ideal para colgantes.',
    short_description: 'Veneciana 1mm, 45cm en oro 18k',
    base_price_cents: 35_000, compare_at_price_cents: nil,
    sku: 'CA-VEN-001', featured: false, status: 'active',
    attributes: { tipo: 'Veneciana', grosor: '1mm', largo: '45+5cm' }
  },
  {
    name: 'Cadena Rolo Mediana',
    category: 'Cadenas Finas',
    description: 'Cadena rolo con eslabones redondos de 2mm. Largo: 50cm. Cierre de langosta. Oro blanco 18k. Versátil y elegante.',
    short_description: 'Rolo 2mm, 50cm en oro blanco 18k',
    base_price_cents: 42_000, compare_at_price_cents: nil,
    sku: 'CA-ROL-002', featured: false, status: 'active',
    attributes: { tipo: 'Rolo', grosor: '2mm', largo: '50cm' }
  },
  {
    name: 'Cadena Cubana Gruesa',
    category: 'Cadenas Gruesas',
    description: 'Cadena cubana (Miami Cuban Link) de 6mm. Largo: 55cm. Cierre de caja con seguro. Oro amarillo 18k macizo. Peso: 45g.',
    short_description: 'Cubana Miami 6mm, 55cm oro 18k macizo',
    base_price_cents: 320_000, compare_at_price_cents: nil,
    sku: 'CA-CUB-003', featured: false, status: 'active',
    attributes: { tipo: 'Cuban Link', grosor: '6mm', peso: '45g' }
  },
  {
    name: 'Cadena Rope Torzal',
    category: 'Cadenas Gruesas',
    description: 'Cadena rope (torzal) de 3mm con textura trenzada. Largo: 50cm. Oro amarillo 18k. Peso: 18g. Brillo excepcional por la textura.',
    short_description: 'Torzal 3mm, 50cm en oro 18k',
    base_price_cents: 125_000, compare_at_price_cents: nil,
    sku: 'CA-ROP-004', featured: false, status: 'active',
    attributes: { tipo: 'Rope/Torzal', grosor: '3mm', peso: '18g' }
  },
  {
    name: 'Cadena Singapur Plata',
    category: 'Cadenas Finas',
    description: 'Cadena Singapur trenzada de 1.5mm en plata 925 con baño de rodio. Largo: 45cm. Brillo intenso, resistente al deslustre.',
    short_description: 'Singapur 1.5mm plata 925 rodio',
    base_price_cents: 8_500, compare_at_price_cents: 12_000,
    sku: 'CA-SIN-005', featured: false, status: 'active',
    attributes: { tipo: 'Singapur', grosor: '1.5mm', material: 'Plata 925 + Rodio' }
  },

  # --- GEMAS Y PIEDRAS (5) ---
  {
    name: 'Diamante Redondo Brillante 1ct',
    category: 'Diamantes',
    description: 'Diamante natural redondo brillante de 1.02ct. Color: G, Claridad: VS1, Corte: Excelente. Triple Ex (corte, pulido, simetría). Certificado GIA.',
    short_description: 'Brillante 1.02ct G/VS1 Triple Ex GIA',
    base_price_cents: 850_000, compare_at_price_cents: nil,
    sku: 'GE-DIA-001', featured: true, status: 'active',
    attributes: { quilates: '1.02ct', color: 'G', claridad: 'VS1', corte: 'Excelente', certificado: 'GIA' }
  },
  {
    name: 'Esmeralda Colombiana Talla Cojín',
    category: 'Esmeraldas',
    description: 'Esmeralda colombiana de Muzo, talla cojín de 2.35ct. Color verde intenso saturado. Tratamiento: aceite menor. Certificado Gübelin.',
    short_description: 'Cojín 2.35ct Muzo, verde intenso',
    base_price_cents: 480_000, compare_at_price_cents: nil,
    sku: 'GE-ESM-002', featured: false, status: 'active',
    attributes: { quilates: '2.35ct', origen: 'Muzo, Colombia', talla: 'Cojín' }
  },
  {
    name: 'Rubí Birmano Talla Óvalo',
    category: 'Piedras Semi-preciosas',
    description: 'Rubí birmano sangre de pichón, talla óvalo de 1.85ct. Color rojo intenso con fluorescencia natural. Sin tratamiento térmico. Certificado GRS.',
    short_description: 'Óvalo 1.85ct sangre de pichón, sin tratar',
    base_price_cents: 720_000, compare_at_price_cents: nil,
    sku: 'GE-RUB-003', featured: false, status: 'active',
    attributes: { quilates: '1.85ct', origen: 'Birmania', color: 'Sangre de pichón' }
  },
  {
    name: 'Zafiro Ceilán Azul Royal',
    category: 'Piedras Semi-preciosas',
    description: 'Zafiro de Sri Lanka (Ceilán) azul royal, talla cojín de 3.10ct. Sin tratamiento térmico. Saturación excepcional. Certificado GRS.',
    short_description: 'Cojín 3.10ct azul royal, sin tratar',
    base_price_cents: 560_000, compare_at_price_cents: nil,
    sku: 'GE-ZAF-004', featured: false, status: 'active',
    attributes: { quilates: '3.10ct', origen: 'Sri Lanka', color: 'Azul Royal' }
  },
  {
    name: 'Set Amatistas Calibradas',
    category: 'Piedras Semi-preciosas',
    description: 'Set de 5 amatistas redondas calibradas de 6mm cada una (total ~3.5ct). Color púrpura intenso uniforme. Ideales para joyería personalizada.',
    short_description: '5 amatistas redondas 6mm (~3.5ct total)',
    base_price_cents: 12_000, compare_at_price_cents: 15_000,
    sku: 'GE-AMA-005', featured: false, status: 'active',
    attributes: { quilates: '~3.5ct total', piezas: '5', tamaño: '6mm c/u' }
  },

  # --- SETS Y CONJUNTOS (4) ---
  {
    name: 'Set Novia Perlas Clásico',
    category: 'Sets y Conjuntos',
    description: 'Set completo de novia: collar de perlas Akoya 7mm (45cm), aretes studs a juego, y pulsera de una vuelta. Broches en oro blanco 18k con diamantes.',
    short_description: 'Collar + aretes + pulsera perlas Akoya',
    base_price_cents: 185_000, compare_at_price_cents: 220_000,
    sku: 'SE-NOV-001', featured: true, status: 'active',
    attributes: { piezas: 'Collar + Aretes + Pulsera', piedra: 'Perla Akoya 7mm' }
  },
  {
    name: 'Set Esmeralda Colombiana',
    category: 'Sets y Conjuntos',
    description: 'Set coordinado: aretes colgantes con esmeraldas (2.4ct total) y colgante con esmeralda (1.5ct). Halos de diamantes. Oro blanco 18k.',
    short_description: 'Aretes + colgante esmeralda con diamantes',
    base_price_cents: 445_000, compare_at_price_cents: nil,
    sku: 'SE-ESM-002', featured: false, status: 'active',
    attributes: { piezas: 'Aretes + Colgante', piedra: 'Esmeralda 3.9ct total' }
  },
  {
    name: 'Set Diario Minimalista',
    category: 'Sets y Conjuntos',
    description: 'Set para uso diario: studs punto de luz (0.1ct c/u), colgante solitario (0.15ct) y pulsera con diamante (0.1ct). Oro amarillo 14k.',
    short_description: 'Studs + colgante + pulsera diamantes 14k',
    base_price_cents: 62_000, compare_at_price_cents: 78_000,
    sku: 'SE-DIA-003', featured: false, status: 'active',
    attributes: { piezas: 'Studs + Colgante + Pulsera', quilates: '0.45ct total' }
  },
  {
    name: 'Set Regalo Aniversario',
    category: 'Sets y Conjuntos',
    description: 'Set aniversario en caja de presentación premium: collar tennis de zafiros, aretes a juego y anillo three-stone. Oro blanco 18k.',
    short_description: 'Collar + aretes + anillo zafiros oro blanco',
    base_price_cents: 395_000, compare_at_price_cents: nil,
    sku: 'SE-ANI-004', featured: false, status: 'draft',
    attributes: { piezas: 'Collar + Aretes + Anillo', piedra: 'Zafiro Azul' }
  }
]

# Variant templates per category type
variant_templates = {
  rings: {
    materials: [
      { name: 'Oro Amarillo 18k', price_modifier: 0 },
      { name: 'Oro Blanco 18k', price_modifier: 500 },
      { name: 'Oro Rosa 18k', price_modifier: 300 },
      { name: 'Platino 950', price_modifier: 15_000 }
    ],
    sizes: ['6', '7', '8', '9', '10']
  },
  earrings: {
    materials: [
      { name: 'Oro Amarillo 18k', price_modifier: 0 },
      { name: 'Oro Blanco 18k', price_modifier: 500 },
      { name: 'Oro Rosa 18k', price_modifier: 300 }
    ]
  },
  bracelets: {
    materials: [
      { name: 'Oro Amarillo 18k', price_modifier: 0 },
      { name: 'Oro Blanco 18k', price_modifier: 500 },
      { name: 'Oro Rosa 18k', price_modifier: 300 }
    ],
    sizes: ['16cm', '17cm', '18cm', '19cm', '20cm']
  },
  necklaces: {
    materials: [
      { name: 'Oro Amarillo 18k', price_modifier: 0 },
      { name: 'Oro Blanco 18k', price_modifier: 500 },
      { name: 'Oro Rosa 18k', price_modifier: 300 }
    ]
  },
  chains: {
    materials: [
      { name: 'Oro Amarillo 18k', price_modifier: 0 },
      { name: 'Oro Blanco 18k', price_modifier: 500 },
      { name: 'Plata 925', price_modifier: -20_000 }
    ]
  },
  gems: nil, # gems don't have material variants
  sets: {
    materials: [
      { name: 'Oro Amarillo 18k', price_modifier: 0 },
      { name: 'Oro Blanco 18k', price_modifier: 1_500 }
    ]
  }
}

def category_type_for(category_name)
  case category_name
  when /Anillo|Alianza|Sello/ then :rings
  when /Stud|Arete|Argolla|Ear Cuff/ then :earrings
  when /Pulsera|Brazalete|Manilla/ then :bracelets
  when /Collar|Colgante|Gargantilla/ then :necklaces
  when /Cadena/ then :chains
  when /Diamante|Esmeralda|Rubí|Zafiro|Amatista|Piedra/ then :gems
  when /Set/ then :sets
  else :necklaces
  end
end

products = []
products_data.each_with_index do |pd, i|
  category = all_categories[pd[:category]] || all_categories.values.first

  product = Product.find_or_create_by!(name: pd[:name], store: store) do |p|
    p.category = category
    p.description = pd[:description]
    p.short_description = pd[:short_description]
    p.base_price_cents = pd[:base_price_cents]
    p.base_price_currency = 'USD'
    p.compare_at_price_cents = pd[:compare_at_price_cents]
    p.compare_at_price_currency = 'USD' if pd[:compare_at_price_cents]
    p.sku = pd[:sku]
    p.track_inventory = true
    p.quantity = rand(3..35)
    p.status = pd[:status]
    p.featured = pd[:featured]
    p.position = i
    p.published_at = pd[:status] == 'active' ? Time.current - rand(1..180).days : nil
    p.custom_attributes = pd[:attributes]
  end
  products << product

  # Create variants based on category type
  cat_type = category_type_for(pd[:category])
  template = variant_templates[cat_type]
  next unless template

  template[:materials].each_with_index do |mat, vi|
    adjusted_price = [pd[:base_price_cents] + mat[:price_modifier], 100].max

    if template[:sizes]
      template[:sizes].each_with_index do |size, si|
        ProductVariant.find_or_create_by!(
          product: product,
          name: "#{mat[:name]} / Talla #{size}",
          store: store
        ) do |v|
          v.sku = "#{pd[:sku]}-#{mat[:name][0..2].upcase}#{size}"
          v.price_cents = adjusted_price
          v.price_currency = 'USD'
          v.track_inventory = true
          v.quantity = rand(0..8)
          v.options = { material: mat[:name], talla: size }
          v.position = vi * template[:sizes].size + si
          v.active = true
        end
      end
    else
      ProductVariant.find_or_create_by!(
        product: product,
        name: mat[:name],
        store: store
      ) do |v|
        v.sku = "#{pd[:sku]}-#{mat[:name][0..2].upcase}"
        v.price_cents = adjusted_price
        v.price_currency = 'USD'
        v.track_inventory = true
        v.quantity = rand(1..12)
        v.options = { material: mat[:name] }
        v.position = vi
        v.active = true
      end
    end
  end
end

active_products = products.select { |p| p.status == 'active' }
variant_count = ProductVariant.where(store: store).count
puts "  Products: #{products.count} created (#{active_products.count} active, #{products.count - active_products.count} draft/archived)"
puts "  Variants: #{variant_count} created"

# =============================================================================
# CUSTOMERS (20)
# =============================================================================
customers_data = [
  { first: 'María', last: 'González', email: 'maria.gonzalez@gmail.com', phone: '+57 310 234 5678', marketing: true },
  { first: 'Carlos', last: 'Rodríguez', email: 'carlos.rodriguez@hotmail.com', phone: '+57 315 876 5432', marketing: true },
  { first: 'Valentina', last: 'López', email: 'vale.lopez@gmail.com', phone: '+57 300 123 4567', marketing: true },
  { first: 'Andrés', last: 'Martínez', email: 'andres.mtz@outlook.com', phone: '+57 312 345 6789', marketing: false },
  { first: 'Camila', last: 'Hernández', email: 'camila.hdz@gmail.com', phone: '+57 318 765 4321', marketing: true },
  { first: 'Santiago', last: 'García', email: 'santi.garcia@yahoo.com', phone: '+57 305 432 1098', marketing: false },
  { first: 'Isabella', last: 'Ramírez', email: 'isa.ramirez@gmail.com', phone: '+57 311 987 6543', marketing: true },
  { first: 'Sebastián', last: 'Torres', email: 'seb.torres@outlook.com', phone: '+57 320 654 3210', marketing: true },
  { first: 'Luciana', last: 'Morales', email: 'luciana.morales@gmail.com', phone: '+57 316 210 9876', marketing: false },
  { first: 'Daniel', last: 'Vargas', email: 'daniel.vargas@hotmail.com', phone: '+57 301 567 8901', marketing: true },
  { first: 'Sofía', last: 'Castro', email: 'sofia.castro@gmail.com', phone: '+57 314 890 1234', marketing: true },
  { first: 'Alejandro', last: 'Mendoza', email: 'ale.mendoza@gmail.com', phone: '+57 319 012 3456', marketing: false },
  { first: 'Gabriela', last: 'Reyes', email: 'gabi.reyes@outlook.com', phone: '+57 302 345 6780', marketing: true },
  { first: 'Mateo', last: 'Díaz', email: 'mateo.diaz@gmail.com', phone: '+57 313 678 9012', marketing: true },
  { first: 'Mariana', last: 'Gutiérrez', email: 'mariana.gtz@yahoo.com', phone: '+57 317 901 2345', marketing: false },
  { first: 'Nicolás', last: 'Peña', email: 'nico.pena@gmail.com', phone: '+57 304 234 5670', marketing: true },
  { first: 'Paula', last: 'Sánchez', email: 'paula.sanchez@hotmail.com', phone: '+57 310 567 8903', marketing: true },
  { first: 'Julián', last: 'Ortiz', email: 'julian.ortiz@gmail.com', phone: '+57 321 890 1236', marketing: false },
  { first: 'Laura', last: 'Jiménez', email: 'laura.jimenez@outlook.com', phone: '+57 308 123 4569', marketing: true },
  { first: 'Felipe', last: 'Rojas', email: 'felipe.rojas@gmail.com', phone: '+57 315 456 7892', marketing: true }
]

customers = customers_data.map do |cd|
  Customer.find_or_create_by!(email: cd[:email], store: store) do |c|
    c.first_name = cd[:first]
    c.last_name = cd[:last]
    c.phone = cd[:phone]
    c.password = 'password123'
    c.password_confirmation = 'password123'
    c.accepts_marketing = cd[:marketing]
  end
end
puts "  Customers: #{customers.count} created"

# =============================================================================
# ORDERS (~110 orders distributed over 12 months)
# =============================================================================
puts "  Creating orders..."

# Colombian cities for shipping addresses
colombian_addresses = [
  { city: 'Bogotá', state: 'DC', zip: '110111' },
  { city: 'Medellín', state: 'ANT', zip: '050001' },
  { city: 'Cali', state: 'VAC', zip: '760001' },
  { city: 'Barranquilla', state: 'ATL', zip: '080001' },
  { city: 'Cartagena', state: 'BOL', zip: '130001' },
  { city: 'Bucaramanga', state: 'SAN', zip: '680001' },
  { city: 'Pereira', state: 'RIS', zip: '660001' },
  { city: 'Santa Marta', state: 'MAG', zip: '470001' },
  { city: 'Manizales', state: 'CAL', zip: '170001' },
  { city: 'Ibagué', state: 'TOL', zip: '730001' }
]

colombian_streets = [
  'Calle 85 #15-40', 'Carrera 7 #72-13', 'Calle 100 #8A-55', 'Carrera 43A #1-50',
  'Calle 10 #4-40', 'Avenida El Poblado #1A-120', 'Calle 53 #46-192', 'Carrera 15 #93-47',
  'Calle 72 #10-07', 'Avenida 19 #104-37', 'Carrera 11 #82-01', 'Calle 93 #13-45',
  'Carrera 50 #52-345', 'Calle 34 #65-12', 'Avenida Circunvalar #20-15'
]

# Monthly distribution (more orders in Dec/Feb/May for holidays)
monthly_weights = {
  1 => 8,   # Enero
  2 => 12,  # Febrero (San Valentín)
  3 => 7,   # Marzo (Día de la Mujer)
  4 => 6,   # Abril
  5 => 11,  # Mayo (Día de la Madre)
  6 => 7,   # Junio
  7 => 6,   # Julio
  8 => 5,   # Agosto
  9 => 8,   # Septiembre (Amor y Amistad)
  10 => 7,  # Octubre
  11 => 8,  # Noviembre
  12 => 15  # Diciembre (Navidad)
}

# Status distribution for completed orders
status_distribution = [
  :delivered, :delivered, :delivered, :delivered, :delivered,  # 50% delivered
  :shipped, :shipped,                                          # 20% shipped
  :paid, :paid,                                                # 20% paid/processing
  :cancelled                                                   # 10% cancelled
]

order_count = 0
orders_created = []

monthly_weights.each do |month, weight|
  # Use current year for recent months, last year for future months
  year = month <= Time.current.month ? Time.current.year : Time.current.year - 1

  weight.times do
    customer = customers.sample
    addr = colombian_addresses.sample
    order_products = active_products.sample(rand(1..4))
    target_status = status_distribution.sample

    # For recent orders (last 2 months), allow pending/confirmed statuses too
    months_ago = ((Time.current.year - year) * 12) + (Time.current.month - month)
    if months_ago <= 1
      target_status = [:pending, :confirmed, :delivered, :shipped, :paid].sample
    end

    # Generate a random date within the month
    day = rand(1..28)
    placed_date = Time.zone.local(year, month, day, rand(8..22), rand(0..59))

    subtotal = 0
    items_data = order_products.map do |p|
      qty = rand(1..2)
      price = p.base_price_cents
      total = price * qty
      subtotal += total
      { product: p, quantity: qty, price: price, total: total }
    end

    tax = (subtotal * 0.19).to_i # Colombian IVA 19%
    shipping = subtotal >= 200_000 ? 0 : 15_000 # Free shipping over $200

    # Determine timestamps based on target status
    paid_at = nil
    shipped_at = nil
    delivered_at = nil
    cancelled_at = nil

    case target_status
    when :confirmed
      # Just confirmed, no payment yet
    when :paid
      paid_at = placed_date + rand(1..3).hours
    when :shipped
      paid_at = placed_date + rand(1..3).hours
      shipped_at = placed_date + rand(1..4).days
    when :delivered
      paid_at = placed_date + rand(1..3).hours
      shipped_at = placed_date + rand(1..4).days
      delivered_at = shipped_at + rand(2..7).days
    when :cancelled
      cancelled_at = placed_date + rand(1..48).hours
    end

    shipping_addr = {
      line1: colombian_streets.sample,
      city: addr[:city],
      state: addr[:state],
      zip: addr[:zip],
      country: 'CO'
    }

    order = Order.create!(
      store: store,
      customer: customer,
      email: customer.email,
      status: target_status.to_s,
      subtotal_cents: subtotal,
      tax_cents: tax,
      total_cents: subtotal + tax + shipping,
      shipping_address: shipping_addr,
      billing_address: shipping_addr, # Same as shipping for simplicity
      notes: [nil, nil, nil, 'Envolver para regalo', 'Entregar en portería', 'Llamar antes de entregar', 'Es un regalo de aniversario'].sample,
      placed_at: placed_date,
      paid_at: paid_at,
      shipped_at: shipped_at,
      delivered_at: delivered_at,
      cancelled_at: cancelled_at,
      created_at: placed_date,
      updated_at: [paid_at, shipped_at, delivered_at, cancelled_at, placed_date].compact.max
    )

    items_data.each do |item|
      variant = item[:product].variants.sample
      order.order_items.create!(
        product: item[:product],
        product_variant: variant,
        product_name: item[:product].name,
        sku: variant&.sku || item[:product].sku,
        quantity: item[:quantity],
        unit_price_cents: item[:price],
        unit_price_currency: 'USD',
        total_cents: item[:total],
        total_currency: 'USD',
        variant_name: variant&.name
      )
    end

    orders_created << order
    order_count += 1
  end
end

status_counts = orders_created.group_by(&:status).transform_values(&:count)
puts "    #{order_count} orders created:"
status_counts.each { |status, count| puts "      - #{status}: #{count}" }

# =============================================================================
# CARTS (8: active + abandoned)
# =============================================================================
puts "  Creating carts..."

# Active carts (customers currently browsing)
active_cart_customers = customers.sample(4)
active_cart_customers.each do |customer|
  cart = Cart.create!(
    store: store,
    customer: customer,
    status: 'active'
  )

  rand(1..3).times do
    product = active_products.sample
    variant = product.variants.sample
    cart.add_item(product, variant, rand(1..2))
  end
end

# Abandoned carts (customers who left without purchasing)
abandoned_cart_customers = (customers - active_cart_customers).sample(4)
abandoned_cart_customers.each do |customer|
  cart = Cart.create!(
    store: store,
    customer: customer,
    status: 'abandoned',
    created_at: rand(3..30).days.ago,
    updated_at: rand(1..15).days.ago
  )

  rand(1..4).times do
    product = active_products.sample
    variant = product.variants.sample
    cart.add_item(product, variant, rand(1..2))
  end
end

# Anonymous abandoned cart (no customer)
anon_cart = Cart.create!(
  store: store,
  customer: nil,
  status: 'abandoned',
  created_at: 5.days.ago,
  updated_at: 5.days.ago
)
2.times do
  product = active_products.sample
  anon_cart.add_item(product, product.variants.sample, 1)
end

total_carts = Cart.where(store: store).count
active_carts = Cart.where(store: store).active.count
abandoned_carts = Cart.where(store: store).abandoned.count
puts "    #{total_carts} carts (#{active_carts} active, #{abandoned_carts} abandoned)"

# =============================================================================
# SUMMARY
# =============================================================================
puts ""
puts "=" * 60
puts "  Seed Complete - Samdalth Gold"
puts "=" * 60
puts ""
puts "  Store:      #{store.name}"
puts "  Users:      #{User.where(store: store).count}"
puts "  Categories: #{Category.where(store: store).root.count} principales + #{Category.where(store: store).count - Category.where(store: store).root.count} sub"
puts "  Products:   #{Product.where(store: store).count} (#{Product.where(store: store, status: 'active').count} active)"
puts "  Variants:   #{ProductVariant.where(store: store).count}"
puts "  Customers:  #{Customer.where(store: store).count}"
puts "  Orders:     #{Order.where(store: store).count}"
puts "  Carts:      #{Cart.where(store: store).count}"
puts ""
puts "  Login: samuel@samdalthgold.com / password123"
puts ""
