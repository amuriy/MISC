 -- Table: public.geomultyline

-- DROP TABLE public.geomultyline;

CREATE TABLE public.geomultyline
(
  objectid uuid NOT NULL DEFAULT nextval_uuid(), -- Уникальный идентификатор объекта в системе
  shape geometry(MultiLineString,4326), -- Геометрия (пространственные данные) линейного(ломаная линия) объекта
  id character varying(255) NOT NULL, -- Идентификатор объекта во внешней системе
  nsi_id character varying(255), -- Идентификатор в единой справочной системе
  parent_id character varying(255), -- Идентификатор объекта во внешней системе
  class_id character varying(64) NOT NULL, -- Код объекта по классификатору КЭУЗ ОО 2012
  sign_angle real DEFAULT 0, -- Угол наклона знака при отображении на карте. Значение по умолчанию: 0
  name character varying(255), -- Наименование объекта
  label character varying(255), -- Надпись объекта, отображаемая на карте
  value character varying(255), -- Значащая величина, характерная для объекта
  link character varying(255), -- Ссылка для запроса карточки объекта (для систем с серверной частью)
  create_user character varying(128) DEFAULT "current_user"(), -- Системное поле – имя пользователя, от имени которого создан объект
  create_date timestamp with time zone DEFAULT now(), -- Системное поле – дата и время создания объекта
  update_user character varying(128) DEFAULT "current_user"(), -- Системное поле – имя пользователя, обновившего объект
  update_date timestamp with time zone DEFAULT now(), -- Системное поле – дата и время обновления объекта
  system_id uuid, -- Системное поле – уникальный идентификатор внешней системы, из которой получен объект
  attributes xml, -- Атрибуты (формуляр) объекта, хранимый в формате XML
  classif_id integer, -- Идентификатор классификатора условных знаков (по словарю системы), по содержанию которого создан класскод УЗ( закодирован, структурирован в поле class_id).
  libclass_id uuid, -- Идентификатор библиотеки условных знаков (пользователя или системы).
  layer_id uuid, -- Идентификатор слоя(пользовательского) -  владельца записи данных пользователя, т.е. слоя, в котором создана запись данных.
  time_data timestamp with time zone, -- Дата-время данных(местоположения,состояния объекта), которые содержит(описывает) запись таблицы.
  graph text, -- Данные графического представления отображаемого знака (xml - svg)
  CONSTRAINT geomultyline_pkey PRIMARY KEY (objectid),
  CONSTRAINT fk_line_classif_id_dictionar_id FOREIGN KEY (classif_id)
      REFERENCES public.dictionar (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT fk_line_layer_id_layer_theme_id FOREIGN KEY (layer_id)
      REFERENCES gip.layer_theme (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT fk_line_libclass_id_lib_classif_id FOREIGN KEY (libclass_id)
      REFERENCES gip.lib_classif (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT geomultyline_idx UNIQUE (id, class_id) -- Уникальный индекс для записи объекта из внешней системы
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.geomultyline
  OWNER TO "BPD_OWNERS";
GRANT ALL ON TABLE public.geomultyline TO "BPD_OWNERS";
GRANT SELECT ON TABLE public.geomultyline TO "BPD_READERS";
COMMENT ON TABLE public.geomultyline
  IS 'Данные объектов, геопространственное положение которых описыватся линиями.';
COMMENT ON COLUMN public.geomultyline.objectid IS 'Уникальный идентификатор объекта в системе';
COMMENT ON COLUMN public.geomultyline.shape IS 'Геометрия (пространственные данные) линейного(ломаная линия) объекта';
COMMENT ON COLUMN public.geomultyline.id IS 'Идентификатор объекта во внешней системе';
COMMENT ON COLUMN public.geomultyline.nsi_id IS 'Идентификатор в единой справочной системе';
COMMENT ON COLUMN public.geomultyline.parent_id IS 'Идентификатор объекта во внешней системе';
COMMENT ON COLUMN public.geomultyline.class_id IS 'Код объекта по классификатору КЭУЗ ОО 2012 ';
COMMENT ON COLUMN public.geomultyline.sign_angle IS 'Угол наклона знака при отображении на карте. Значение по умолчанию: 0';
COMMENT ON COLUMN public.geomultyline.name IS 'Наименование объекта';
COMMENT ON COLUMN public.geomultyline.label IS 'Надпись объекта, отображаемая на карте';
COMMENT ON COLUMN public.geomultyline.value IS 'Значащая величина, характерная для объекта';
COMMENT ON COLUMN public.geomultyline.link IS 'Ссылка для запроса карточки объекта (для систем с серверной частью)';
COMMENT ON COLUMN public.geomultyline.create_user IS 'Системное поле – имя пользователя, от имени которого создан объект';
COMMENT ON COLUMN public.geomultyline.create_date IS 'Системное поле – дата и время создания объекта';
COMMENT ON COLUMN public.geomultyline.update_user IS 'Системное поле – имя пользователя, обновившего объект';
COMMENT ON COLUMN public.geomultyline.update_date IS 'Системное поле – дата и время обновления объекта';
COMMENT ON COLUMN public.geomultyline.system_id IS 'Системное поле – уникальный идентификатор внешней системы, из которой получен объект';
COMMENT ON COLUMN public.geomultyline.attributes IS 'Атрибуты (формуляр) объекта, хранимый в формате XML';
COMMENT ON COLUMN public.geomultyline.classif_id IS 'Идентификатор классификатора условных знаков (по словарю системы), по содержанию которого создан класскод УЗ( закодирован, структурирован в поле class_id).';
COMMENT ON COLUMN public.geomultyline.libclass_id IS 'Идентификатор библиотеки условных знаков (пользователя или системы).';
COMMENT ON COLUMN public.geomultyline.layer_id IS 'Идентификатор слоя(пользовательского) -  владельца записи данных пользователя, т.е. слоя, в котором создана запись данных.';
COMMENT ON COLUMN public.geomultyline.time_data IS 'Дата-время данных(местоположения,состояния объекта), которые содержит(описывает) запись таблицы.';
COMMENT ON COLUMN public.geomultyline.graph IS 'Данные графического представления отображаемого знака (xml - svg)';

COMMENT ON CONSTRAINT geomultyline_idx ON public.geomultyline IS 'Уникальный индекс для записи объекта из внешней системы';


-- Index: public.idx_line_class_id

-- DROP INDEX public.idx_line_class_id;

CREATE INDEX idx_line_class_id
  ON public.geomultyline
  USING btree
  (class_id COLLATE pg_catalog."default" varchar_pattern_ops);

-- Index: public.idx_line_id

-- DROP INDEX public.idx_line_id;

CREATE INDEX idx_line_id
  ON public.geomultyline
  USING btree
  (id COLLATE pg_catalog."default");

-- Index: public.idx_line_system_id

-- DROP INDEX public.idx_line_system_id;

CREATE INDEX idx_line_system_id
  ON public.geomultyline
  USING btree
  (system_id);

-- Index: public.sidx_geomultyline_shape

-- DROP INDEX public.sidx_geomultyline_shape;

CREATE INDEX sidx_geomultyline_shape
  ON public.geomultyline
  USING gist
  (shape);


-- Trigger: geomultyline_update on public.geomultyline

-- DROP TRIGGER geomultyline_update ON public.geomultyline;

CREATE TRIGGER geomultyline_update
  BEFORE UPDATE
  ON public.geomultyline
  FOR EACH ROW
  EXECUTE PROCEDURE public.htsts_change_tracking();

-- Trigger: line_del_attr on public.geomultyline

-- DROP TRIGGER line_del_attr ON public.geomultyline;

CREATE TRIGGER line_del_attr
  AFTER DELETE
  ON public.geomultyline
  FOR EACH ROW
  EXECUTE PROCEDURE public.geodata_del_attr();


 -- Table: public.geomultypoint

-- DROP TABLE public.geomultypoint;

CREATE TABLE public.geomultypoint
(
  objectid uuid NOT NULL DEFAULT nextval_uuid(), -- Уникальный идентификатор объекта в системе
  shape geometry(MultiPoint,4326), -- Геометрия (пространственные данные) точечного объекта
  id character varying(255) NOT NULL, -- Идентификатор объекта во внешней системе
  nsi_id character varying(255), -- Идентификатор в единой справочной системе
  parent_id character varying(255), -- Идентификатор объекта во внешней системе
  class_id character varying(64) NOT NULL, -- Код объекта по классификатору КЭУЗ ОО 2012
  sign_angle real DEFAULT 0, -- Угол наклона знака при отображении на карте. Значение по умолчанию: 0
  name character varying(255), -- Наименование объекта
  label character varying(255), -- Надпись объекта, отображаемая на карте
  value character varying(255), -- Значащая величина, характерная для объекта
  link character varying(255), -- Ссылка для запроса карточки объекта (для систем с серверной частью)
  create_user character varying(128) DEFAULT "current_user"(), -- Системное поле – имя пользователя, от имени которого создан объект
  create_date timestamp with time zone DEFAULT now(), -- Системное поле – дата и время создания объекта
  update_user character varying(128) DEFAULT "current_user"(), -- Системное поле – имя пользователя, обновившего объект
  update_date timestamp with time zone DEFAULT now(), -- Системное поле – дата и время обновления объекта
  system_id uuid, -- Системное поле – уникальный идентификатор внешней системы, из которой получен объект
  attributes xml, -- Атрибуты (формуляр) объекта, хранимый в формате XML
  url_video character varying(255),
  classif_id integer, -- Идентификатор классификатора условных знаков (по словарю системы), по содержанию которого создан класскод УЗ( закодирован, структурирован в поле class_id).
  libclass_id uuid, -- Идентификатор библиотеки условных знаков (пользователя или системы).
  layer_id uuid, -- Идентификатор слоя(пользовательского) -  владельца записи данных пользователя, т.е. слоя, в котором создана запись данных.
  time_data timestamp with time zone, -- Дата-время данных(местоположения,состояния объекта), которые содержит(описывает) запись таблицы.
  graph text, -- Данные графического представления отображаемого знака (xml - svg)
  CONSTRAINT geomultypoint_pkey PRIMARY KEY (objectid),
  CONSTRAINT fk_point_classif_id_dictionar_id FOREIGN KEY (classif_id)
      REFERENCES public.dictionar (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT fk_point_layer_id_layer_theme_id FOREIGN KEY (layer_id)
      REFERENCES gip.layer_theme (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT fk_point_libclass_id_lib_classif_id FOREIGN KEY (libclass_id)
      REFERENCES gip.lib_classif (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT geomultypoint_idx UNIQUE (id, class_id) -- Уникальный индекс для записи объекта из внешней системы
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.geomultypoint
  OWNER TO "BPD_OWNERS";
GRANT ALL ON TABLE public.geomultypoint TO "BPD_OWNERS";
GRANT SELECT ON TABLE public.geomultypoint TO "BPD_READERS";
COMMENT ON TABLE public.geomultypoint
  IS 'Данные объектов, геопространственное положение которых описыватся точками.';
COMMENT ON COLUMN public.geomultypoint.objectid IS 'Уникальный идентификатор объекта в системе';
COMMENT ON COLUMN public.geomultypoint.shape IS 'Геометрия (пространственные данные) точечного объекта';
COMMENT ON COLUMN public.geomultypoint.id IS 'Идентификатор объекта во внешней системе';
COMMENT ON COLUMN public.geomultypoint.nsi_id IS 'Идентификатор в единой справочной системе';
COMMENT ON COLUMN public.geomultypoint.parent_id IS 'Идентификатор объекта во внешней системе';
COMMENT ON COLUMN public.geomultypoint.class_id IS 'Код объекта по классификатору КЭУЗ ОО 2012 ';
COMMENT ON COLUMN public.geomultypoint.sign_angle IS 'Угол наклона знака при отображении на карте. Значение по умолчанию: 0';
COMMENT ON COLUMN public.geomultypoint.name IS 'Наименование объекта';
COMMENT ON COLUMN public.geomultypoint.label IS 'Надпись объекта, отображаемая на карте';
COMMENT ON COLUMN public.geomultypoint.value IS 'Значащая величина, характерная для объекта';
COMMENT ON COLUMN public.geomultypoint.link IS 'Ссылка для запроса карточки объекта (для систем с серверной частью)';
COMMENT ON COLUMN public.geomultypoint.create_user IS 'Системное поле – имя пользователя, от имени которого создан объект';
COMMENT ON COLUMN public.geomultypoint.create_date IS 'Системное поле – дата и время создания объекта';
COMMENT ON COLUMN public.geomultypoint.update_user IS 'Системное поле – имя пользователя, обновившего объект';
COMMENT ON COLUMN public.geomultypoint.update_date IS 'Системное поле – дата и время обновления объекта';
COMMENT ON COLUMN public.geomultypoint.system_id IS 'Системное поле – уникальный идентификатор внешней системы, из которой получен объект';
COMMENT ON COLUMN public.geomultypoint.attributes IS 'Атрибуты (формуляр) объекта, хранимый в формате XML';
COMMENT ON COLUMN public.geomultypoint.classif_id IS 'Идентификатор классификатора условных знаков (по словарю системы), по содержанию которого создан класскод УЗ( закодирован, структурирован в поле class_id).';
COMMENT ON COLUMN public.geomultypoint.libclass_id IS 'Идентификатор библиотеки условных знаков (пользователя или системы).';
COMMENT ON COLUMN public.geomultypoint.layer_id IS 'Идентификатор слоя(пользовательского) -  владельца записи данных пользователя, т.е. слоя, в котором создана запись данных.';
COMMENT ON COLUMN public.geomultypoint.time_data IS 'Дата-время данных(местоположения,состояния объекта), которые содержит(описывает) запись таблицы.';
COMMENT ON COLUMN public.geomultypoint.graph IS 'Данные графического представления отображаемого знака (xml - svg)';

COMMENT ON CONSTRAINT geomultypoint_idx ON public.geomultypoint IS 'Уникальный индекс для записи объекта из внешней системы';


-- Index: public.idx_point_class_id

-- DROP INDEX public.idx_point_class_id;

CREATE INDEX idx_point_class_id
  ON public.geomultypoint
  USING btree
  (class_id COLLATE pg_catalog."default" varchar_pattern_ops);

-- Index: public.idx_point_id

-- DROP INDEX public.idx_point_id;

CREATE INDEX idx_point_id
  ON public.geomultypoint
  USING btree
  (id COLLATE pg_catalog."default");

-- Index: public.idx_point_system_id

-- DROP INDEX public.idx_point_system_id;

CREATE INDEX idx_point_system_id
  ON public.geomultypoint
  USING btree
  (system_id);

-- Index: public.sidx_geomultypoint_shape

-- DROP INDEX public.sidx_geomultypoint_shape;

CREATE INDEX sidx_geomultypoint_shape
  ON public.geomultypoint
  USING gist
  (shape);


-- Trigger: geomultypoint_update on public.geomultypoint

-- DROP TRIGGER geomultypoint_update ON public.geomultypoint;

CREATE TRIGGER geomultypoint_update
  BEFORE UPDATE
  ON public.geomultypoint
  FOR EACH ROW
  EXECUTE PROCEDURE public.htsts_change_tracking();

-- Trigger: point_del_attr on public.geomultypoint

-- DROP TRIGGER point_del_attr ON public.geomultypoint;

CREATE TRIGGER point_del_attr
  AFTER DELETE
  ON public.geomultypoint
  FOR EACH ROW
  EXECUTE PROCEDURE public.geodata_del_attr();


(16:59) a.tyukina: -- Table: public.geomultypolygon

-- DROP TABLE public.geomultypolygon;

CREATE TABLE public.geomultypolygon
(
  objectid uuid NOT NULL DEFAULT nextval_uuid(), -- Уникальный идентификатор объекта в системе
  shape geometry(MultiPolygon,4326), -- Геометрия (пространственные данные) полигонального (замкнутая ломаная линия) объекта
  id character varying(255) NOT NULL, -- Идентификатор объекта во внешней системе
  nsi_id character varying(255), -- Идентификатор в единой справочной системе
  parent_id character varying(255), -- Идентификатор объекта во внешней системе
  class_id character varying(64) NOT NULL, -- Код объекта по классификатору КЭУЗ ОО 2012
  sign_angle real DEFAULT 0, -- Угол наклона знака при отображении на карте. Значение по умолчанию: 0
  name character varying(255), -- Наименование объекта
  label character varying(255), -- Надпись объекта, отображаемая на карте
  value character varying(255), -- Значащая величина, характерная для объекта
  link character varying(255), -- Ссылка для запроса карточки объекта (для систем с серверной частью)
  create_user character varying(128) DEFAULT "current_user"(), -- Системное поле – имя пользователя, от имени которого создан объект
  create_date timestamp with time zone DEFAULT now(), -- Системное поле – дата и время создания объекта
  update_user character varying(128) DEFAULT "current_user"(), -- Системное поле – имя пользователя, обновившего объект
  update_date timestamp with time zone DEFAULT now(), -- Системное поле – дата и время обновления объекта
  system_id uuid, -- Системное поле – уникальный идентификатор внешней системы, из которой получен объект
  attributes xml, -- Атрибуты (формуляр) объекта, хранимый в формате XML
  classif_id integer, -- Идентификатор классификатора условных знаков (по словарю системы), по содержанию которого создан класскод УЗ( закодирован, структурирован в поле class_id).
  libclass_id uuid, -- Идентификатор библиотеки условных знаков (пользователя или системы).
  layer_id uuid, -- Идентификатор слоя(пользовательского) -  владельца записи данных пользователя, т.е. слоя, в котором создана запись данных.
  time_data timestamp with time zone, -- Дата-время данных(местоположения,состояния объекта), которые содержит(описывает) запись таблицы.
  graph text, -- Данные графического представления отображаемого знака (xml - svg)
  CONSTRAINT geomultypolygon_pkey PRIMARY KEY (objectid),
  CONSTRAINT fk_polygon_classif_id_dictionar_id FOREIGN KEY (classif_id)
      REFERENCES public.dictionar (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT fk_polygon_layer_id_layer_theme_id FOREIGN KEY (layer_id)
      REFERENCES gip.layer_theme (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT fk_polygon_libclass_id_lib_classif_id FOREIGN KEY (libclass_id)
      REFERENCES gip.lib_classif (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT geomultypolygon_idx UNIQUE (id, class_id) -- Уникальный индекс для записи объекта из внешней системы
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.geomultypolygon
  OWNER TO "BPD_OWNERS";
GRANT ALL ON TABLE public.geomultypolygon TO "BPD_OWNERS";
GRANT SELECT ON TABLE public.geomultypolygon TO "BPD_READERS";
COMMENT ON TABLE public.geomultypolygon
  IS 'Данные объектов, геопространственное положение которых описыватся точками.';
COMMENT ON COLUMN public.geomultypolygon.objectid IS 'Уникальный идентификатор объекта в системе';
COMMENT ON COLUMN public.geomultypolygon.shape IS 'Геометрия (пространственные данные) полигонального (замкнутая ломаная линия) объекта';
COMMENT ON COLUMN public.geomultypolygon.id IS 'Идентификатор объекта во внешней системе';
COMMENT ON COLUMN public.geomultypolygon.nsi_id IS 'Идентификатор в единой справочной системе';
COMMENT ON COLUMN public.geomultypolygon.parent_id IS 'Идентификатор объекта во внешней системе';
COMMENT ON COLUMN public.geomultypolygon.class_id IS 'Код объекта по классификатору КЭУЗ ОО 2012 ';
COMMENT ON COLUMN public.geomultypolygon.sign_angle IS 'Угол наклона знака при отображении на карте. Значение по умолчанию: 0';
COMMENT ON COLUMN public.geomultypolygon.name IS 'Наименование объекта';
COMMENT ON COLUMN public.geomultypolygon.label IS 'Надпись объекта, отображаемая на карте';
COMMENT ON COLUMN public.geomultypolygon.value IS 'Значащая величина, характерная для объекта';
COMMENT ON COLUMN public.geomultypolygon.link IS 'Ссылка для запроса карточки объекта (для систем с серверной частью)';
COMMENT ON COLUMN public.geomultypolygon.create_user IS 'Системное поле – имя пользователя, от имени которого создан объект';
COMMENT ON COLUMN public.geomultypolygon.create_date IS 'Системное поле – дата и время создания объекта';
COMMENT ON COLUMN public.geomultypolygon.update_user IS 'Системное поле – имя пользователя, обновившего объект';
COMMENT ON COLUMN public.geomultypolygon.update_date IS 'Системное поле – дата и время обновления объекта';
COMMENT ON COLUMN public.geomultypolygon.system_id IS 'Системное поле – уникальный идентификатор внешней системы, из которой получен объект';
COMMENT ON COLUMN public.geomultypolygon.attributes IS 'Атрибуты (формуляр) объекта, хранимый в формате XML';
COMMENT ON COLUMN public.geomultypolygon.classif_id IS 'Идентификатор классификатора условных знаков (по словарю системы), по содержанию которого создан класскод УЗ( закодирован, структурирован в поле class_id).';
COMMENT ON COLUMN public.geomultypolygon.libclass_id IS 'Идентификатор библиотеки условных знаков (пользователя или системы).';
COMMENT ON COLUMN public.geomultypolygon.layer_id IS 'Идентификатор слоя(пользовательского) -  владельца записи данных пользователя, т.е. слоя, в котором создана запись данных.';
COMMENT ON COLUMN public.geomultypolygon.time_data IS 'Дата-время данных(местоположения,состояния объекта), которые содержит(описывает) запись таблицы.';
COMMENT ON COLUMN public.geomultypolygon.graph IS 'Данные графического представления отображаемого знака (xml - svg)';

COMMENT ON CONSTRAINT geomultypolygon_idx ON public.geomultypolygon IS 'Уникальный индекс для записи объекта из внешней системы';


-- Index: public.idx_poligon_system_id

-- DROP INDEX public.idx_poligon_system_id;

CREATE INDEX idx_poligon_system_id
  ON public.geomultypolygon
  USING btree
  (system_id);

-- Index: public.idx_polygon_class_id

-- DROP INDEX public.idx_polygon_class_id;

CREATE INDEX idx_polygon_class_id
  ON public.geomultypolygon
  USING btree
  (class_id COLLATE pg_catalog."default" varchar_pattern_ops);

-- Index: public.idx_polygon_id

-- DROP INDEX public.idx_polygon_id;

CREATE INDEX idx_polygon_id
  ON public.geomultypolygon
  USING btree
  (id COLLATE pg_catalog."default");

-- Index: public.sidx_geomultypolygon_shape

-- DROP INDEX public.sidx_geomultypolygon_shape;

CREATE INDEX sidx_geomultypolygon_shape
  ON public.geomultypolygon
  USING gist
  (shape);


-- Trigger: geomultypolygon_update on public.geomultypolygon

-- DROP TRIGGER geomultypolygon_update ON public.geomultypolygon;

CREATE TRIGGER geomultypolygon_update
  BEFORE UPDATE
  ON public.geomultypolygon
  FOR EACH ROW
  EXECUTE PROCEDURE public.htsts_change_tracking();

-- Trigger: polygon_del_attr on public.geomultypolygon

-- DROP TRIGGER polygon_del_attr ON public.geomultypolygon;

CREATE TRIGGER polygon_del_attr
  AFTER DELETE
  ON public.geomultypolygon
  FOR EACH ROW
  EXECUTE PROCEDURE public.geodata_del_attr();
