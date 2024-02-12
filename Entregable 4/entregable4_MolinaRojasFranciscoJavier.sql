--Para comenzar con los cambios de diseño, ejecutando este script desde la teminal de psql uno piensa que las tablas se crearan en la base de datos "empresa" creada al principio de este
--Sin embargo cuando lo ejecuto, la base de datos se crea vacia y se queda vacia, debido a que las tablas se estan creando en la base de datos base del sistema.
--Para solucionar este inconveniente, bastaria con eliminar la sentencia "CREATE DATABASE", añadir la base de datos manualmente, conectarse a ella y ya ahi ejecutar el script.
--Dejo los comandos a realizar desde la terminal de psql:
--CREATE DATABASE empresa;
--\c empresa

-- Una vez hecho los cambios, si ejecutamos de nuevo el script con \i nombre.sql, obtenemos este fallo producido posteriormente a los drop de las tablas autores y titulos entre otros: psql:entregable4_MolinaRojasFranciscoJavier.sql:38: ERROR:  relation "editores" does not exist
--El problema esta localizado en la creación de la tabla titulos, especificamente en la sentencia: CONSTRAINT titulos_ibfk_1 FOREIGN KEY (edt_id) REFERENCES editores (edt_id).
--En esta sentencia se esta intentando asignar una clave foranea desde la tabla titulos hacia la tabla editores y en ese scope o en esa parte de codigo aun no se ha definido la tabla editores.
--Para solucionarlo reordenare los "DROP TABLE" y "CREATE TABLE" deforma en la que no se puedan producir esta clase de errores.
--Organizandolo, podemos encontrar otro error en la tabla descuentos (clave foranea a tieda), otro en empleados (clave foranea a puestos)
--Como resultado, obtenemos en orden las siguientes tablas:

--Cuando solucionamos esto, podemos ver ejecutando el script que las tablas se nos crean de manera satisfactoria, pero sin embargo en los inserts se producen una serie de errores, entre ellos tenemos por ejemplo el siguiente: psql:entregable4_MolinaRojasFranciscoJavier.sql:164: ERROR:  insert or update on table "descuentos" violates foreign key constraint "descuentos_ibfk_1"
--DETAIL:  Key (tda_id)=(0   ) is not present in table "tiendas".

--Para ver si el problema puede ser el orden de los inserts, reordenamos los inserts con el mismo orden que le damos a la creacion de tablas.

--A pesar de solucionar casi todos los problemas, solo queda uno con el siguiente mensaje de error:psql:entregable4_MolinaRojasFranciscoJavier.sql:218: ERROR:  insert or update on table "descuentos" violates foreign key constraint "descuentos_ibfk_1"
--DETAIL:  Key (tda_id)=(0   ) is not present in table "tiendas".

--Como podemos ver en los inserts de descuento (los dos primeros), los id de las tienda que proporcinan, no se corresponden con ninguna de las tiendas insertadas anteriormente, e incluso se estan introduciendo enteros donde deberain ir cadenas, por lo que, para solucionarlo cambiaré el valor de dicho id por el de alguna tienda existente.

--Con esto, al ejecutar el script no tendriamos ningun tipo de fallo y las tablas y datos son creados perfectamente.

DROP TABLE IF EXISTS autores CASCADE;
CREATE TABLE autores (
au_id char(11) NOT NULL,
apellidos varchar(40) NOT NULL,
nombre varchar(20) NOT NULL,
tlf char(12) NOT NULL,
direccion varchar(40) default NULL,
ciudad varchar(20) default NULL,
estado char(2) default NULL,
cp char(5) default NULL,
contrato bit(1) NOT NULL,
PRIMARY KEY (au_id)
);

DROP TABLE IF EXISTS editores CASCADE;
CREATE TABLE editores (
edt_id char(4) NOT NULL,
edt_nombre varchar(40) default NULL,
ciudad varchar(20) default NULL,
estado char(2) default NULL,
pais varchar(30) default NULL,
PRIMARY KEY (edt_id)
);

DROP TABLE IF EXISTS tiendas CASCADE;
CREATE TABLE tiendas (
tda_id char(4) NOT NULL,
tda_nombre varchar(40) default NULL,
tda_direccion varchar(40) default NULL,
ciudad varchar(20) default NULL,
estado char(2) default NULL,
cp char(5) default NULL,
PRIMARY KEY (tda_id)
);

DROP TABLE IF EXISTS puestos CASCADE;
CREATE TABLE puestos (
pto_id smallint NOT NULL,
job_desc varchar(50) NOT NULL default 'New Position - puesto no formalizado todavia',
min_nvl smallint NOT NULL,
max_nvl smallint NOT NULL,
PRIMARY KEY (pto_id)
);

DROP TABLE IF EXISTS titulos CASCADE;
CREATE TABLE titulos (
titulo_id char(6) NOT NULL default '',
titulo varchar(80) NOT NULL,
tipo char(12) NOT NULL default 'UNDECIDED',
edt_id char(4) default NULL,
precio int default NULL,
avance int default NULL,
comision int default NULL,
cant_ventas int default NULL,
notas varchar(200) default NULL,
fchpub timestamp NOT NULL default CURRENT_TIMESTAMP,
PRIMARY KEY (titulo_id),
CONSTRAINT titulos_ibfk_1 FOREIGN KEY (edt_id) REFERENCES editores (edt_id)
);

DROP TABLE IF EXISTS descuentos CASCADE;
CREATE TABLE descuentos (
tipodescuento varchar(40) NOT NULL,
tda_id char(4) default NULL,
rangomenor smallint default NULL,
rangomayor smallint default NULL,
descuento decimal(4,2) NOT NULL,
CONSTRAINT descuentos_ibfk_1 FOREIGN KEY (tda_id) REFERENCES tiendas(tda_id)
);


DROP TABLE IF EXISTS empleados CASCADE;
CREATE TABLE empleados (
emp_id char(9) NOT NULL default '',
nombre varchar(20) NOT NULL,
inicial char(1) default NULL,
apellidos varchar(30) NOT NULL,
pto_id smallint NOT NULL default '1',
job_nvl smallint NOT NULL default '10',
edt_id char(4) NOT NULL default '9952',
fch_contrato timestamp NOT NULL default CURRENT_TIMESTAMP,
-- PRIMARY KEY (emp_id, edt_id, pto_id),
CONSTRAINT empleados_ibfk_1 FOREIGN KEY (edt_id) REFERENCES editores (edt_id),
CONSTRAINT empleados_ibfk_2 FOREIGN KEY (pto_id) REFERENCES puestos (pto_id)
);

DROP TABLE IF EXISTS comisiones CASCADE;
CREATE TABLE comisiones (
titulo_id char(6) default NULL,
rangomin int default NULL,
rangomax int default NULL,
comision int default NULL,
-- PRIMARY KEY (titulo_id),
CONSTRAINT comisiones_ibfk_1 FOREIGN KEY (titulo_id) REFERENCES titulos (titulo_id)
);


DROP TABLE IF EXISTS tituloautor CASCADE;
CREATE TABLE tituloautor (
au_id char(11) NOT NULL default '',
titulo_id char(6) NOT NULL default '',
au_ord smallint default NULL,
tipocomision int default NULL,
PRIMARY KEY (au_id,titulo_id),
CONSTRAINT tituloautor_ibfk_1 FOREIGN KEY (au_id) REFERENCES autores (au_id),
CONSTRAINT tituloautor_ibfk_2 FOREIGN KEY (titulo_id) REFERENCES titulos (titulo_id)
);

DROP TABLE IF EXISTS ventas CASCADE;
CREATE TABLE ventas (
tda_id char(4) NOT NULL,
ord_num varchar(20) NOT NULL,
ord_fch timestamp NOT NULL default CURRENT_TIMESTAMP,
cant smallint NOT NULL,
modopago varchar(12) NOT NULL,
titulo_id char(6) NOT NULL default '',
PRIMARY KEY (tda_id,ord_num,titulo_id),
CONSTRAINT ventas_ibfk_1 FOREIGN KEY (tda_id) REFERENCES tiendas (tda_id),
CONSTRAINT ventas_ibfk_2 FOREIGN KEY (titulo_id) REFERENCES titulos (titulo_id)
);


INSERT INTO autores VALUES ('172-32-1176','White','Johnson','408 496-7223','10932 Bigge Rd.','Menlo Park','CA','94025','1'),
('213-46-8915','Green','Marjorie','415 986-7020','309 63rd St. #411','Oakland','CA','94618','1'),
('238-95-7766','Carson','Cheryl','415 548-7723','589 Darwin Ln.','Berkeley','CA','94705','1'),
('267-41-2394','Leary','Michael','408 286-2428','22 Cleveland Av. #14','San Jose','CA','95128','1'),
('274-80-9391','Straight','Dean','415 834-2919','5420 College Av.','Oakland','CA','94609','1'),
('341-22-1782','Smith','Meander','913 843-0462','10 Mississippi Dr.','Lawrence','KS','66044','0'),
('409-56-7008','Bennet','Abraham','415 658-9932','6223 Bateman St.','Berkeley','CA','94705','1'),
('427-17-2319','Dull','Ann','415 836-7128','3410 Blonde St.','Palo Alto','CA','94301','1'),
('472-27-2349','Gringlesby','Burt','707 938-6445','PO Box 792','Covelo','CA','95428','1'),
('486-29-1786','Locksley','Charlene','415 585-4620','18 Broadway Av.','San Francisco','CA','94130','1'),
('527-72-3246','Greene','Morningstar','615 297-2723','22 Graybar House Rd.','Nashville','TN','37215','0');
INSERT INTO autores VALUES ('648-92-1872','Blotchet-Halls','Reginald','503 745-6402','55 Hillsdale Bl.','Corvallis','OR','97330','1'),
('672-71-3249','Yokomoto','Akiko','415 935-4228','3 Silver Ct.','Walnut Creek','CA','94595','1'),
('712-45-1867','del Castillo','Innes','615 996-8275','2286 Cram Pl. #86','Ann Arbor','MI','48105','1'),
('722-51-5454','DeFrance','Michel','219 547-9982','3 Balding Pl.','Gary','IN','46403','1'),
('724-08-9931','Stringer','Dirk','415 843-2991','5420 Telegraph Av.','Oakland','CA','94609','0'),
('724-80-9391','MacFeather','Stearns','415 354-7128','44 Upland Hts.','Oakland','CA','94612','1'),
('756-30-7391','Karsen','Livia','415 534-9219','5720 McAuley St.','Oakland','CA','94609','1'),
('807-91-6654','Panteley','Sylvia','301 946-8853','1956 Arlington Pl.','Rockville','MD','20853','1'),
('846-92-7186','Hunter','Sheryl','415 836-7128','3410 Blonde St.','Palo Alto','CA','94301','1'),
('893-72-1158','McBadden','Heather','707 448-4982','301 Putnam','Vacaville','CA','95688','0'),
('899-46-2035','Ringer','Anne','801 826-0752','67 Seventh Av.','Salt Lake ciudad','UT','84152','1');
INSERT INTO autores VALUES ('998-72-3567','Ringer','Albert','801 826-0752','67 Seventh Av.','Salt Lake ciudad','UT','84152','1');

INSERT INTO editores VALUES ('0736','New Moon Books','Boston','MA','USA'),
('0877','Binnet & Hardley','Washington','DC','USA'),
('1389','Algodata Infosystems','Berkeley','CA','USA'),
('1622','Five Lakes Publishing','Chicago','IL','USA'),
('1756','Ramona editores','Dallas','TX','USA'),
('9901','GGG&G','Munchen',NULL,'Germany'),
('9952','Scootney Books','New York','NY','USA'),
('9999','Lucerne Publishing','Paris',NULL,'France');

INSERT INTO tiendas VALUES ('6380','Eric the Read Books','788 Catamaugus Ave.','Seattle','WA','98056'),
('7066','Barnums','567 Pasadena Ave.','Tustin','CA','92789'),
('7067','News & Brews','577 First St.','Los Gatos','CA','96745'),
('7131','Doc-U-Mat: Quality Laundry and Books','24-A Avogadro Way','Remulade','WA','98014'),
('7896','Fricative Bookshop','89 Madison St.','Fremont','CA','90019'),
('8042','Bookbeat','679 Carson St.','Portland','OR','89076');

INSERT INTO puestos VALUES (1,'New Hire - Job not specified',10,10),
(2,'Chief Executive Officer',127,127),
(3,'Business Operations Manager',127,127),
(4,'Chief Financial Officier',127,127),
(5,'Publisher',127,127),
(6,'Managing Editor',127,127),
(7,'Marketing Manager',120,127),
(8,'Public Relations Manager',100,127),
(9,'Acquisitions Manager',75,127),
(10,'Productions Manager',75,127),
(11,'Operations Manager',75,127),
(12,'Editor',25,100),
(13,'ventas Representative',25,100),
(14,'Designer',25,100);

INSERT INTO titulos VALUES ('BU1032','The Busy Executives Database Guide','business','1389',20,5000,10,4095,'An overview of available database systems with emphasis on common business applications. Illustrated.',now()),
('BU1111','Cooking with Computers: Surreptitious Balance Sheets','business','1389',12,5000,10,3876,'Helpful hints on how to use your electronic resources to the best advantage.',now()),
('BU2075','You Can Combat Computer Stress!','business','0736',3,10125,24,18722,'The latest medical and psychological techniques for living with the electronic office. Easy-to-understand explanations.',now()),
('BU7832','Straight Talk About Computers','business','1389',20,5000,10,4095,'Annotated analysis of what computers can do for you: a no- hype guide for the critical user.',now()),
('MC2222','Silicon Valley Gastronomic Treats','mod_cook','0877',20,0,12,2032,'Favorite recipes for quick, easy, and elegant meals.',now()),
('MC3021','The Gourmet Microwave','mod_cook','0877',3,15000,24,22246,'Traditional French gourmet recipes adapted for modern microwave cooking.',now());
INSERT INTO titulos VALUES ('MC3026','The Psychology of Computer Cooking','UNDECIDED','0877',NULL,NULL,NULL,NULL,NULL,'2008-01-10 16:37:30'),
('PC1035','But Is It User Friendly?','popular_comp','1389',23,7000,16,8780,'A survey of software for the naive user, focusing on the friendliness of each.',now()),
('PC8888','Secrets of Silicon Valley','popular_comp','1389',20,8000,10,4095,'Muckraking reporting on the worlds largest computer hardware and software manufacturers.',now()),
('PC9999','Net Etiquette','popular_comp','1389',NULL,NULL,NULL,NULL,'A must-read for computer conferencing.','2008-01-10 16:37:30'),
('PS1372','Computer Phobic AND Non-Phobic Individuals: Behavior Variations','psychology','0877',22,7000,10,375,'A must for the specialist, this book examines the difference between those who hate and fear computers and those who dont.',now()),
('PS2091','Is Anger the Enemy?','psychology','0736',11,2275,12,2045,'Carefully researched study of the effects of strong emotions on the body. Metabolic charts included.',now()),
('PS2106','Life Without Fear','psychology','0736',7,6000,10,111,'New exercise, meditation, and nutritional techniques that can reduce the shock of daily interactions. Popular audience. Sample menus included, exercise video available separately.',now());
INSERT INTO titulos VALUES ('PS3333','Prolonged Data Deprivation: Four Case Studies','psychology','0736',20,2000,10,4072,'What happens when the data runs dry? Searching evaluations of information-shortage effects.',now()),
('PS7777','Emotional Security: A New Algorithm','psychology','0736',8,4000,10,3336,'Protecting yourself and your loved ones from undue emotional stress in the modern world. Use of computer and nutritional aids emphasized.',now()),
('TC3218','Onions, Leeks, and Garlic: Cooking Secrets of the Mediterranean','trad_cook','0877',21,7000,10,375,'Profusely illustrated in color, this makes a wonderful gift book for a cuisine-oriented friend.',now()),
('TC4203','Fifty Years in Buckingham Palace Kitchens','trad_cook','0877',12,4000,14,15096,'More anecdotes from the Queens favorite cook describing life among English comision. Recipes, techniques, tender vignettes.',now()),
('TC7777','Sushi, Anyone?','trad_cook','0877',15,8000,10,4095,'Detailed instructions on how to make authentic Japanese sushi in your spare time.',now());

INSERT INTO descuentos VALUES ('Initial Customer','7066',NULL,NULL,'10.50'),
('Volume descuento','7066',100,1000,'6.70'),
('Customer descuento','8042',NULL,NULL,'5.00');

INSERT INTO empleados VALUES ('A-C71970F','Aria','','Cruz',10,87,'1389',now()),
('A-R89858F','Annette','','Roulet',6,127,'9999',now()),
('AMD15433F','Ann','M','Devon',3,127,'9952',now()),
('ARD36773F','Anabela','R','Domingues',8,100,'0877',now()),
('CFH28514M','Carlos','F','Hernadez',5,127,'9999',now()),
('CGS88322F','Carine','G','Schmitt',13,64,'1389',now()),
('DBT39435M','Daniel','B','Tonini',11,75,'0877',now()),
('DWR65030M','Diego','W','Roel',6,127,'1389',now()),
('ENL44273F','Elizabeth','N','Lincoln',14,35,'0877',now()),
('F-C16315M','Francisco','','Chang',4,127,'9952',now()),
('GHT50241M','Gary','H','Thomas',9,127,'0736',now()),
('H-B39728F','Helen','','Bennett',12,35,'0877',now()),
('HAN90777M','Helvetius','A','Nagy',7,120,'9999',now()),
('HAS54740M','Howard','A','Snyder',12,100,'0736',now()),
('JYL26161F','Janine','Y','Labrune',5,127,'9901',now());
INSERT INTO empleados VALUES ('KFJ64308F','Karin','F','Josephs',14,100,'0736',now()),
('KJJ92907F','Karla','J','Jablonski',9,127,'9999',now()),
('L-B31947F','Lesley','','Brown',7,120,'0877',now()),
('LAL21447M','Laurence','A','Lebihan',5,127,'0736',now()),
('M-L67958F','Maria','','Larsson',7,127,'1389',now()),
('M-P91209M','Manuel','','Pereira',8,101,'9999',now()),
('M-R38834F','Martine','','Rance',9,75,'0877',now()),
('MAP77183M','Miguel','A','Paolino',11,112,'1389',now()),
('MAS70474F','Margaret','A','Smith',9,78,'1389',now()),
('MFS52347M','Martin','F','Sommer',10,127,'0736',now()),
('MGK44605M','Matti','G','Karttunen',6,127,'0736',now()),
('MJP25939M','Maria','J','Pontes',5,127,'1756',now()),
('MMS49649F','Mary','M','Saveley',8,127,'0736',now()),
('PCM98509F','Patricia','C','McKenna',11,127,'9999',now()),
('PDI47470M','Palle','D','Ibsen',7,127,'0736',now());
INSERT INTO empleados VALUES ('PHF38899M','Peter','H','Franken',10,75,'0877',now()),
('PMA42628M','Paolo','M','Accorti',13,35,'0877',now()),
('POK93028M','Pirkko','O','Koskitalo',10,80,'9999',now()),
('PSA89086M','Pedro','S','Afonso',14,89,'1389',now()),
('PSP68661F','Paula','S','Parente',8,125,'1389',now()),
('PTC11962M','Philip','T','Cramer',2,127,'9952',now()),
('PXH22250M','Paul','X','Henriot',5,127,'0877',now()),
('R-M53550M','Roland','','Mendel',11,127,'0736',now()),
('RBM23061F','Rita','B','Muller',5,127,'1622',now()),
('SKO22412M','Sven','K','Ottlieb',5,127,'1389',now()),
('TPO55093M','Timothy','P','Rourke',13,100,'0736',now()),
('VPA30890F','Victoria','P','Ashworth',6,127,'0877',now()),
('Y-L77953M','Yoshi','','Latimer',12,32,'1389',now());

INSERT INTO comisiones VALUES ('BU1032',0,5000,10),
('BU1032',5001,50000,12),
('PC1035',0,2000,10),
('PC1035',2001,3000,12),
('PC1035',3001,4000,14),
('PC1035',4001,10000,16),
('PC1035',10001,50000,18),
('BU2075',0,1000,10),
('BU2075',1001,3000,12),
('BU2075',3001,5000,14),
('BU2075',5001,7000,16),
('BU2075',7001,10000,18),
('BU2075',10001,12000,20),
('BU2075',12001,14000,22),
('BU2075',14001,50000,24),
('PS2091',0,1000,10),
('PS2091',1001,5000,12),
('PS2091',5001,10000,14),
('PS2091',10001,50000,16),
('PS2106',0,2000,10),
('PS2106',2001,5000,12),
('PS2106',5001,10000,14),
('PS2106',10001,50000,16),
('MC3021',0,1000,10),
('MC3021',1001,2000,12),
('MC3021',2001,4000,14),
('MC3021',4001,6000,16),
('MC3021',6001,8000,18),
('MC3021',8001,10000,20),
('MC3021',10001,12000,22),
('MC3021',12001,50000,24),
('TC3218',0,2000,10),
('TC3218',2001,4000,12),
('TC3218',4001,6000,14),
('TC3218',6001,8000,16),
('TC3218',8001,10000,18),
('TC3218',10001,12000,20),
('TC3218',12001,14000,22);
INSERT INTO comisiones VALUES ('TC3218',14001,50000,24),
('PC8888',0,5000,10),
('PC8888',5001,10000,12),
('PC8888',10001,15000,14),
('PC8888',15001,50000,16),
('PS7777',0,5000,10),
('PS7777',5001,50000,12),
('PS3333',0,5000,10),
('PS3333',5001,10000,12),
('PS3333',10001,15000,14),
('PS3333',15001,50000,16),
('BU1111',0,4000,10),
('BU1111',4001,8000,12),
('BU1111',8001,10000,14),
('BU1111',12001,16000,16),
('BU1111',16001,20000,18),
('BU1111',20001,24000,20),
('BU1111',24001,28000,22),
('BU1111',28001,50000,24),
('MC2222',0,2000,10),
('MC2222',2001,4000,12),
('MC2222',4001,8000,14),
('MC2222',8001,12000,16),
('MC2222',12001,20000,18),
('MC2222',20001,50000,20),
('TC7777',0,5000,10),
('TC7777',5001,15000,12),
('TC7777',15001,50000,14),
('TC4203',0,2000,10),
('TC4203',2001,8000,12),
('TC4203',8001,16000,14),
('TC4203',16001,24000,16),
('TC4203',24001,32000,18),
('TC4203',32001,40000,20),
('TC4203',40001,50000,22),
('BU7832',0,5000,10),
('BU7832',5001,10000,12),
('BU7832',10001,15000,14);
INSERT INTO comisiones VALUES ('BU7832',15001,20000,16),
('BU7832',20001,25000,18),
('BU7832',25001,30000,20),
('BU7832',30001,35000,22),
('BU7832',35001,50000,24),
('PS1372',0,10000,10),
('PS1372',10001,20000,12),
('PS1372',20001,30000,14),
('PS1372',30001,40000,16),
('PS1372',40001,50000,18);

INSERT INTO tituloautor VALUES ('172-32-1176','PS3333',1,100),
('213-46-8915','BU1032',2,40),
('213-46-8915','BU2075',1,100),
('238-95-7766','PC1035',1,100),
('267-41-2394','BU1111',2,40),
('267-41-2394','TC7777',2,30),
('274-80-9391','BU7832',1,100),
('409-56-7008','BU1032',1,60),
('427-17-2319','PC8888',1,50),
('472-27-2349','TC7777',3,30),
('486-29-1786','PC9999',1,100),
('486-29-1786','PS7777',1,100),
('648-92-1872','TC4203',1,100),
('672-71-3249','TC7777',1,40),
('712-45-1867','MC2222',1,100),
('722-51-5454','MC3021',1,75),
('724-80-9391','BU1111',1,60),
('724-80-9391','PS1372',2,25),
('756-30-7391','PS1372',1,75),
('807-91-6654','TC3218',1,100),
('846-92-7186','PC8888',2,50),
('899-46-2035','MC3021',2,25),
('899-46-2035','PS2091',2,50),
('998-72-3567','PS2091',1,50),
('998-72-3567','PS2106',1,100);

INSERT INTO ventas VALUES ('6380','6871',now(),5,'Net 60','BU1032'),
('6380','722a',now(),3,'Net 60','PS2091'),
('7066','A2976',now(),50,'Net 30','PC8888'),
('7066','QA7442.3',now(),75,'ON invoice','PS2091'),
('7067','D4482',now(),10,'Net 60','PS2091'),
('7067','P2121',now(),40,'Net 30','TC3218'),
('7067','P2121',now(),20,'Net 30','TC4203'),
('7067','P2121',now(),20,'Net 30','TC7777'),
('7131','N914008',now(),20,'Net 30','PS2091'),
('7131','N914014',now(),25,'Net 30','MC3021'),
('7131','P3087a',now(),20,'Net 60','PS1372'),
('7131','P3087a',now(),25,'Net 60','PS2106'),
('7131','P3087a',now(),15,'Net 60','PS3333'),
('7131','P3087a',now(),25,'Net 60','PS7777'),
('7896','QQ2299',now(),15,'Net 60','BU7832'),
('7896','TQ456',now(),10,'Net 60','MC2222'),
('7896','X999',now(),35,'ON invoice','BU2075');
INSERT INTO ventas VALUES ('8042','423LL922',now(),15,'ON invoice','MC3021'),
('8042','423LL930',now(),10,'ON invoice','BU1032'),
('8042','P723',now(),25,'Net 30','BU1111'),
('8042','QA879.1',now(),30,'Net 30','PC1035');

--Para la segunda parte del entregable, implementaremos dos disparadores, siendo uno de estos un que proteja de borrado a la tabla ventas.

--Para el disparador de borrado he usado de referencia uno visto en clase:
CREATE OR REPLACE FUNCTION EvitarBorrado() RETURNS TRIGGER AS
$EvitarBorrado$ 
   DECLARE
   BEGIN
   RETURN NULL;
   END;
$EvitarBorrado$ LANGUAGE plpgsql;

CREATE TRIGGER EvitarBorrado BEFORE DELETE ON ventas FOR EACH ROW
EXECUTE PROCEDURE EvitarBorrado();

--El siguiente disparador mantendra un registro o "log" de las filas que se eliminen de la tabla comisiones
DROP TABLE IF EXISTS logComisiones CASCADE;
CREATE TABLE logComisiones (
    titulo_id char(6) NOT NULL,
    fecha_elim timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Crear la función que se ejecutará en el disparador
DROP FUNCTION IF EXISTS logComisiones;
CREATE OR REPLACE FUNCTION logComisiones() RETURNS TRIGGER AS
$logComisiones$
   BEGIN
      INSERT INTO logComisiones (titulo_id)
      VALUES (OLD.titulo_id);
      RETURN OLD;
   END;
$logComisiones$ LANGUAGE plpgsql;

-- Crear el nuevo disparador
CREATE TRIGGER logComisiones
BEFORE DELETE ON comisiones
FOR EACH ROW
EXECUTE PROCEDURE logComisiones();

