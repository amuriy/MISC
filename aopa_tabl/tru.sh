(16:53) a.tyukina: -- Table: is_aopa."geoMultyLine"

-- DROP TABLE is_aopa."geoMultyLine";

CREATE TABLE is_aopa."geoMultyLine"
(
-- Унаследована from table geomultyline:  objectid uuid NOT NULL DEFAULT nextval_uuid(),
-- Унаследована from table geomultyline:  shape geometry(MultiLineString,4326),
-- Унаследована from table geomultyline:  id character varying(255) NOT NULL,
-- Унаследована from table geomultyline:  nsi_id character varying(255),
-- Унаследована from table geomultyline:  parent_id character varying(255),
-- Унаследована from table geomultyline:  class_id character varying(64) NOT NULL,
-- Унаследована from table geomultyline:  sign_angle real DEFAULT 0,
-- Унаследована from table geomultyline:  name character varying(255),
-- Унаследована from table geomultyline:  label character varying(255),
-- Унаследована from table geomultyline:  value character varying(255),
-- Унаследована from table geomultyline:  link character varying(255),
-- Унаследована from table geomultyline:  create_user character varying(128) DEFAULT "current_user"(),
-- Унаследована from table geomultyline:  create_date timestamp with time zone DEFAULT now(),
-- Унаследована from table geomultyline:  update_user character varying(128) DEFAULT "current_user"(),
-- Унаследована from table geomultyline:  update_date timestamp with time zone DEFAULT now(),
-- Унаследована from table geomultyline:  system_id uuid DEFAULT '0001f3e4-651f-7888-1234-567890042ae7'::uuid,
-- Унаследована from table geomultyline:  attributes xml,
-- Унаследована from table geomultyline:  classif_id integer,
-- Унаследована from table geomultyline:  libclass_id uuid,
-- Унаследована from table geomultyline:  layer_id uuid,
-- Унаследована from table geomultyline:  time_data timestamp with time zone,
-- Унаследована from table geomultyline:  graph text,
  CONSTRAINT is_aopa_line_pkey PRIMARY KEY (objectid),
  CONSTRAINT fk_is_aopa_classif_id_dictionar_id FOREIGN KEY (classif_id)
      REFERENCES public.dictionar (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT fk_is_aopa_layer_id_layer_theme_id FOREIGN KEY (layer_id)
      REFERENCES gip.layer_theme (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT fk_is_aopa_libclass_id_lib_classif_id FOREIGN KEY (libclass_id)
      REFERENCES gip.lib_classif (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT is_aopa_line_idx UNIQUE (id, class_id)
)
INHERITS (public.geomultyline)
WITH (
  OIDS=FALSE
);
ALTER TABLE is_aopa."geoMultyLine"
  OWNER TO "BPD_OWNERS";
GRANT ALL ON TABLE is_aopa."geoMultyLine" TO "BPD_OWNERS";
GRANT SELECT ON TABLE is_aopa."geoMultyLine" TO "BPD_READERS";

-- Index: is_aopa.idx_line_class_id_is_aopa

-- DROP INDEX is_aopa.idx_line_class_id_is_aopa;

CREATE INDEX idx_line_class_id_is_aopa
  ON is_aopa."geoMultyLine"
  USING btree
  (class_id COLLATE pg_catalog."default" varchar_pattern_ops);

-- Index: is_aopa.idx_line_id_is_aopa

-- DROP INDEX is_aopa.idx_line_id_is_aopa;

CREATE INDEX idx_line_id_is_aopa
  ON is_aopa."geoMultyLine"
  USING btree
  (id COLLATE pg_catalog."default");

-- Index: is_aopa.idx_line_system_id_is_aopa

-- DROP INDEX is_aopa.idx_line_system_id_is_aopa;

CREATE INDEX idx_line_system_id_is_aopa
  ON is_aopa."geoMultyLine"
  USING btree
  (system_id);

-- Index: is_aopa.sidx_line_shape_is_aopa

-- DROP INDEX is_aopa.sidx_line_shape_is_aopa;

CREATE INDEX sidx_line_shape_is_aopa
  ON is_aopa."geoMultyLine"
  USING gist
  (shape);


-- Trigger: is_aopa_line_del_attr on is_aopa."geoMultyLine"

-- DROP TRIGGER is_aopa_line_del_attr ON is_aopa."geoMultyLine";

CREATE TRIGGER is_aopa_line_del_attr
  AFTER DELETE
  ON is_aopa."geoMultyLine"
  FOR EACH ROW
  EXECUTE PROCEDURE public.geodata_del_attr();

-- Trigger: is_aopa_line_update on is_aopa."geoMultyLine"

-- DROP TRIGGER is_aopa_line_update ON is_aopa."geoMultyLine";

CREATE TRIGGER is_aopa_line_update
  BEFORE UPDATE
  ON is_aopa."geoMultyLine"
  FOR EACH ROW
  EXECUTE PROCEDURE public.htsts_change_tracking();


(16:53) a.tyukina: -- Table: is_aopa."geoMultyPoint"

-- DROP TABLE is_aopa."geoMultyPoint";

CREATE TABLE is_aopa."geoMultyPoint"
(
-- Унаследована from table geomultypoint:  objectid uuid NOT NULL DEFAULT nextval_uuid(),
-- Унаследована from table geomultypoint:  shape geometry(MultiPoint,4326),
-- Унаследована from table geomultypoint:  id character varying(255) NOT NULL,
-- Унаследована from table geomultypoint:  nsi_id character varying(255),
-- Унаследована from table geomultypoint:  parent_id character varying(255),
-- Унаследована from table geomultypoint:  class_id character varying(64) NOT NULL,
-- Унаследована from table geomultypoint:  sign_angle real DEFAULT 0,
-- Унаследована from table geomultypoint:  name character varying(255),
-- Унаследована from table geomultypoint:  label character varying(255),
-- Унаследована from table geomultypoint:  value character varying(255),
-- Унаследована from table geomultypoint:  link character varying(255),
-- Унаследована from table geomultypoint:  create_user character varying(128) DEFAULT "current_user"(),
-- Унаследована from table geomultypoint:  create_date timestamp with time zone DEFAULT now(),
-- Унаследована from table geomultypoint:  update_user character varying(128) DEFAULT "current_user"(),
-- Унаследована from table geomultypoint:  update_date timestamp with time zone DEFAULT now(),
-- Унаследована from table geomultypoint:  system_id uuid DEFAULT '0001f3e4-651f-7888-1234-567890042ae7'::uuid,
-- Унаследована from table geomultypoint:  attributes xml,
-- Унаследована from table geomultypoint:  url_video character varying(255),
-- Унаследована from table geomultypoint:  classif_id integer,
-- Унаследована from table geomultypoint:  libclass_id uuid,
-- Унаследована from table geomultypoint:  layer_id uuid,
-- Унаследована from table geomultypoint:  time_data timestamp with time zone,
-- Унаследована from table geomultypoint:  graph text,
  CONSTRAINT is_aopa_point_pkey PRIMARY KEY (objectid),
  CONSTRAINT fk_is_aopa_classif_id_dictionar_id FOREIGN KEY (classif_id)
      REFERENCES public.dictionar (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT fk_is_aopa_layer_id_layer_theme_id FOREIGN KEY (layer_id)
      REFERENCES gip.layer_theme (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT fk_is_aopa_libclass_id_lib_classif_id FOREIGN KEY (libclass_id)
      REFERENCES gip.lib_classif (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT is_aopa_point_idx UNIQUE (id, class_id)
)
INHERITS (public.geomultypoint)
WITH (
  OIDS=FALSE
);
ALTER TABLE is_aopa."geoMultyPoint"
  OWNER TO "BPD_OWNERS";
GRANT ALL ON TABLE is_aopa."geoMultyPoint" TO "BPD_OWNERS";
GRANT SELECT ON TABLE is_aopa."geoMultyPoint" TO "BPD_READERS";

-- Index: is_aopa.idx_point_class_id_is_aopa

-- DROP INDEX is_aopa.idx_point_class_id_is_aopa;

CREATE INDEX idx_point_class_id_is_aopa
  ON is_aopa."geoMultyPoint"
  USING btree
  (class_id COLLATE pg_catalog."default" varchar_pattern_ops);

-- Index: is_aopa.idx_point_id_is_aopa

-- DROP INDEX is_aopa.idx_point_id_is_aopa;

CREATE INDEX idx_point_id_is_aopa
  ON is_aopa."geoMultyPoint"
  USING btree
  (id COLLATE pg_catalog."default");

-- Index: is_aopa.idx_point_system_id_is_aopa

-- DROP INDEX is_aopa.idx_point_system_id_is_aopa;

CREATE INDEX idx_point_system_id_is_aopa
  ON is_aopa."geoMultyPoint"
  USING btree
  (system_id);

-- Index: is_aopa.sidx_point_shape_is_aopa

-- DROP INDEX is_aopa.sidx_point_shape_is_aopa;

CREATE INDEX sidx_point_shape_is_aopa
  ON is_aopa."geoMultyPoint"
  USING gist
  (shape);


-- Trigger: is_aopa_point_del_attr on is_aopa."geoMultyPoint"

-- DROP TRIGGER is_aopa_point_del_attr ON is_aopa."geoMultyPoint";

CREATE TRIGGER is_aopa_point_del_attr
  AFTER DELETE
  ON is_aopa."geoMultyPoint"
  FOR EACH ROW
  EXECUTE PROCEDURE public.geodata_del_attr();

-- Trigger: is_aopa_point_update on is_aopa."geoMultyPoint"

-- DROP TRIGGER is_aopa_point_update ON is_aopa."geoMultyPoint";

CREATE TRIGGER is_aopa_point_update
  BEFORE UPDATE
  ON is_aopa."geoMultyPoint"
  FOR EACH ROW
  EXECUTE PROCEDURE public.htsts_change_tracking();


(16:53) a.tyukina: -- Table: is_aopa."geoMultyPolygon"

-- DROP TABLE is_aopa."geoMultyPolygon";

CREATE TABLE is_aopa."geoMultyPolygon"
(
-- Унаследована from table geomultypolygon:  objectid uuid NOT NULL DEFAULT nextval_uuid(),
-- Унаследована from table geomultypolygon:  shape geometry(MultiPolygon,4326),
-- Унаследована from table geomultypolygon:  id character varying(255) NOT NULL,
-- Унаследована from table geomultypolygon:  nsi_id character varying(255),
-- Унаследована from table geomultypolygon:  parent_id character varying(255),
-- Унаследована from table geomultypolygon:  class_id character varying(64) NOT NULL,
-- Унаследована from table geomultypolygon:  sign_angle real DEFAULT 0,
-- Унаследована from table geomultypolygon:  name character varying(255),
-- Унаследована from table geomultypolygon:  label character varying(255),
-- Унаследована from table geomultypolygon:  value character varying(255),
-- Унаследована from table geomultypolygon:  link character varying(255),
-- Унаследована from table geomultypolygon:  create_user character varying(128) DEFAULT "current_user"(),
-- Унаследована from table geomultypolygon:  create_date timestamp with time zone DEFAULT now(),
-- Унаследована from table geomultypolygon:  update_user character varying(128) DEFAULT "current_user"(),
-- Унаследована from table geomultypolygon:  update_date timestamp with time zone DEFAULT now(),
-- Унаследована from table geomultypolygon:  system_id uuid DEFAULT '0001f3e4-651f-7888-1234-567890042ae7'::uuid,
-- Унаследована from table geomultypolygon:  attributes xml,
-- Унаследована from table geomultypolygon:  classif_id integer,
-- Унаследована from table geomultypolygon:  libclass_id uuid,
-- Унаследована from table geomultypolygon:  layer_id uuid,
-- Унаследована from table geomultypolygon:  time_data timestamp with time zone,
-- Унаследована from table geomultypolygon:  graph text,
  CONSTRAINT is_aopa_molygon_pkey PRIMARY KEY (objectid),
  CONSTRAINT fk_is_aopa_classif_id_dictionar_id FOREIGN KEY (classif_id)
      REFERENCES public.dictionar (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT fk_is_aopa_layer_id_layer_theme_id FOREIGN KEY (layer_id)
      REFERENCES gip.layer_theme (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT fk_is_aopa_libclass_id_lib_classif_id FOREIGN KEY (libclass_id)
      REFERENCES gip.lib_classif (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED,
  CONSTRAINT is_aopa_molygon_idx UNIQUE (id, class_id)
)
INHERITS (public.geomultypolygon)
WITH (
  OIDS=FALSE
);
ALTER TABLE is_aopa."geoMultyPolygon"
  OWNER TO "BPD_OWNERS";
GRANT ALL ON TABLE is_aopa."geoMultyPolygon" TO "BPD_OWNERS";
GRANT SELECT ON TABLE is_aopa."geoMultyPolygon" TO "BPD_READERS";

-- Index: is_aopa.idx_polygon_class_id_is_aopa

-- DROP INDEX is_aopa.idx_polygon_class_id_is_aopa;

CREATE INDEX idx_polygon_class_id_is_aopa
  ON is_aopa."geoMultyPolygon"
  USING btree
  (class_id COLLATE pg_catalog."default" varchar_pattern_ops);

-- Index: is_aopa.idx_polygon_id_is_aopa

-- DROP INDEX is_aopa.idx_polygon_id_is_aopa;

CREATE INDEX idx_polygon_id_is_aopa
  ON is_aopa."geoMultyPolygon"
  USING btree
  (id COLLATE pg_catalog."default");

-- Index: is_aopa.idx_polygon_system_id_is_aopa

-- DROP INDEX is_aopa.idx_polygon_system_id_is_aopa;

CREATE INDEX idx_polygon_system_id_is_aopa
  ON is_aopa."geoMultyPolygon"
  USING btree
  (system_id);

-- Index: is_aopa.sidx_polygon_shape_is_aopa

-- DROP INDEX is_aopa.sidx_polygon_shape_is_aopa;

CREATE INDEX sidx_polygon_shape_is_aopa
  ON is_aopa."geoMultyPolygon"
  USING gist
  (shape);


-- Trigger: is_aopa_polygon_del_attr on is_aopa."geoMultyPolygon"

-- DROP TRIGGER is_aopa_polygon_del_attr ON is_aopa."geoMultyPolygon";

CREATE TRIGGER is_aopa_polygon_del_attr
  AFTER DELETE
  ON is_aopa."geoMultyPolygon"
  FOR EACH ROW
  EXECUTE PROCEDURE public.geodata_del_attr();

-- Trigger: is_aopa_polygon_update on is_aopa."geoMultyPolygon"

-- DROP TRIGGER is_aopa_polygon_update ON is_aopa."geoMultyPolygon";

CREATE TRIGGER is_aopa_polygon_update
  BEFORE UPDATE
  ON is_aopa."geoMultyPolygon"
  FOR EACH ROW
  EXECUTE PROCEDURE public.htsts_change_tracking();


