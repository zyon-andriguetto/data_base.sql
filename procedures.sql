CREATE PROCEDURE procInsertAluno (
	@NOMEALUNO VARCHAR(50)
)AS BEGIN
INSERT ALUNOS(nome) VALUES (@NOMEALUNO)
END;

CREATE PROCEDURE procSetAluno(
  @matricula int,
  @nomealuno varchar(50)
)
AS BEGIN
UPDATE ALUNOS SET nome = @nomealuno WHERE matricula = @matricula
END;

CREATE PROCEDURE procInsertCursos(
	@SIGLACURSO CHAR(3),
  	@NOMECURSO VARCHAR(50)
)AS BEGIN
INSERT CURSOS(siglacurso,nomecurso) VALUES (@SIGLACURSO,@NOMECURSO)
END;

CREATE PROCEDURE procSetNomeCursos(
  @SIGLACURSO CHAR(3),
  @NOMECURSO VARCHAR(50)
)
AS BEGIN
UPDATE CURSOS SET nomecurso = @NOMECURSO WHERE siglacurso = @SIGLACURSO
END;


CREATE PROCEDURE procInsertProfessor(
  	@NOMEPROFESSOR VARCHAR(50)
)AS BEGIN
INSERT PROFESSOR(nomeprofessor) VALUES (@NOMEPROFESSOR)
END

CREATE PROCEDURE procSetProfessor(
  @idprofessor int,
  @nomeprofessor varchar(50)
)
AS BEGIN
UPDATE PROFESSOR SET nomeprofessor = @nomeprofessor WHERE idprofessor = @idprofessor
END;


CREATE PROCEDURE procInsertMaterias(
  @SIGLAMATERIA char(3),
  @NOMEMATERIA VARCHAR(50),
  @CARGAHORARIA FLOAT,
  @SIGLACURSO CHAR(3),
  @IDPROFESSOR INT
)AS BEGIN
INSERT INTO MATERIAS (SIGLAMATERIA, NOMEMATERIA, CARGAHORARIA, SIGLACURSO, IDPROFESSOR)
VALUES (@SIGLAMATERIA, @NOMEMATERIA, @CARGAHORARIA, @SIGLACURSO, @IDPROFESSOR)
END;

	
CREATE OR ALTER PROCEDURE RotinaAluno
(
    @nome varchar(50),
    @siglacurso char(3),
    @perletivo int
)
AS BEGIN
    INSERT ALUNOS(NOME) VALUES (@nome)
    INSERT MATRICULA (IDMATRICULA,SIGLAMATERIA,SIGLACURSO,IDPROFESSOR,PERLETIVO)
    SELECT @@IDENTITY,SIGLAMATERIA,SIGLACURSO,IDPROFESSOR,@perletivo FROM MATERIAS WHERE SIGLACURSO = @siglacurso
END;


CREATE OR ALTER PROCEDURE InsertDadosPadrao
    AS BEGIN
        DECLARE
            @NOMEALUNO varchar(50),
            @NOMEPROFESSOR varchar(50),
            @SIGLACURSO char(3),
            @NOMECURSO varchar(50),
            @NOMEMATERIA varchar(50),
            @SIGLAMATERIA char(3),
            @CARGAHORARIA int,
            @IDPROFESSOR int


        SET @NOMEALUNO = 'Iago'
        SET @NOMEPROFESSOR = 'CaneloAlvarez'
        SET @SIGLACURSO = 'EDS'
        SET @NOMECURSO = 'Engenharia de Software'
        SET @NOMEMATERIA = 'Banco de Dados'
        SET @SIGLAMATERIA = 'BDA'
        SET @CARGAHORARIA = 72
        SET @IDPROFESSOR = 1


        EXEC procInsertAluno @NOMEALUNO;

        EXEC procInsertCursos @SIGLACURSO,@NOMECURSO;

        EXEC procInsertProfessor @NOMEPROFESSOR;

        EXEC procInsertMaterias @SIGLAMATERIA, @NOMEMATERIA, @CARGAHORARIA, @SIGLACURSO, @IDPROFESSOR


END;
    CREATE OR ALTER PROCEDURE procCadastrarNota
    (
        @MATRICULA INT,
        @CURSO CHAR(3),
        @MATERIA CHAR(3),
        @PERLETIVO CHAR(4),
        @NOTA FLOAT,
        @FALTA INT,
        @BIMESTRE INT
    )
    AS
    BEGIN

        IF @BIMESTRE = 1
            BEGIN

                UPDATE MATRICULA
                SET N1 = @NOTA,
                    F1 = @FALTA,
                    TOTALPONTOS = @NOTA,
                    TOTALFALTAS = @FALTA,
                    MEDIA = @NOTA
                WHERE IDMATRICULA = @MATRICULA
                  AND SIGLACURSO = @CURSO
                  AND SIGLAMATERIA = @MATERIA
                  AND PERLETIVO = @PERLETIVO;
            END

        ELSE

            IF @BIMESTRE = 2
                BEGIN

                    UPDATE MATRICULA
                    SET N2 = @NOTA,
                        F2 = @FALTA,
                        TOTALPONTOS = @NOTA + N1,
                        TOTALFALTAS = @FALTA + F1,
                        MEDIA = (@NOTA + N1) / 2
                    WHERE IDMATRICULA = @MATRICULA
                      AND SIGLACURSO = @CURSO
                      AND SIGLAMATERIA = @MATERIA
                      AND PERLETIVO = @PERLETIVO;
                END

            ELSE

                IF @BIMESTRE = 3
                    BEGIN

                        UPDATE MATRICULA
                        SET N3 = @NOTA,
                            F3 = @FALTA,
                            TOTALPONTOS = @NOTA + N1 + N2,
                            TOTALFALTAS = @FALTA + F1 + F2,
                            MEDIA = (@NOTA + N1 + N2) / 3
                        WHERE IDMATRICULA = @MATRICULA
                          AND SIGLACURSO = @CURSO
                          AND SIGLAMATERIA = @MATERIA
                          AND PERLETIVO = @PERLETIVO;
                    END

                ELSE

                    IF @BIMESTRE = 4
                        BEGIN

                            DECLARE
                                @CARGAHORA INT

                            SET @CARGAHORA = (
                                SELECT CARGAHORARIA FROM MATERIAS
                                WHERE       SIGLAMATERIA = @MATERIA
                                  AND SIGLACURSO = @CURSO)

                            UPDATE MATRICULA
                            SET N4 = @NOTA,
                                F4 = @FALTA,
                                TOTALPONTOS = @NOTA + N1 + N2 + N3,
                                TOTALFALTAS = @FALTA + F1 + F2 + F3,
                                MEDIA = (@NOTA + N1 + N2 + N3) / 4


                            UPDATE MATRICULA SET PERCFREQ = (@CARGAHORA - TOTALFALTAS)*100/@CARGAHORA

                            SELECT IDMATRICULA,PERCFREQ,MEDIA,
                                   CASE
                                       WHEN MEDIA < 7 AND MEDIA > 2.99  THEN 'ESTE ALUNO ESTÁ EM EXAME'
                                       WHEN MEDIA < 2.99 OR PERCFREQ < 75 THEN 'ESTE ALUNO REPROVOU DIRETAMENTE'
                                       ELSE 'ESTE ALUNO PASSOU DIRETAMENTE'
                                       END AS STATUSMATRICULA
                            FROM MATRICULA

                            WHERE IDMATRICULA = @MATRICULA
                              AND SIGLACURSO = @CURSO
                              AND SIGLAMATERIA = @MATERIA
                              AND PERLETIVO = @PERLETIVO;
                        END
END;

CREATE OR ALTER PROCEDURE procCadastrarExame(
    @NOTAEXAME FLOAT,
    @MATRICULA INT
)
AS BEGIN
   UPDATE MATRICULA
        SET NOTAEXAME = @NOTAEXAME,
            MEDIAFINAL = (NOTAEXAME + MEDIA) / 2
                WHERE IDMATRICULA = @MATRICULA
END;

CREATE OR ALTER PROCEDURE procInsertCursoEMateria(
        @SIGLACURSO char(3),
        @NOMECURSO varchar(50),
        @SIGLAMATERIA char(3),
        @NOMEMATERIA varchar(50),
        @CARGAHORARIA int,
        @IDPROFESSOR int
)
AS BEGIN
        IF EXISTS (SELECT SIGLACURSO FROM CURSOS WHERE SIGLACURSO <> @SIGLACURSO)
            BEGIN
                INSERT CURSOS(SIGLACURSO,NOMECURSO) VALUES (@SIGLACURSO,@NOMECURSO)
                INSERT MATERIAS (SIGLAMATERIA,NOMEMATERIA,CARGAHORARIA,IDPROFESSOR,SIGLACURSO) VALUES (@SIGLAMATERIA,@NOMEMATERIA,@CARGAHORARIA,@IDPROFESSOR,@SIGLACURSO)
            END
END
