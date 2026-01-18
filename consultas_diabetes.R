# Script para la explotación semántica del grafo RDF de Diabetes Tipo 2

library(SPARQL)
endpoint <- "http://dayhoff.inf.um.es:3048/blazegraph/namespace/diabetes/sparql"


#Función reutilizable para no repetir código
run_query <- function(query) {
  result <- SPARQL(endpoint, query)
  return(result$results)
}

#CONSULTA 1: Proteínas humanas asociadas a Diabetes Tipo 2 y sus genes codificantes
q1 <- "
PREFIX ex: <https://um.es/diabetes/>
PREFIX biolink: <https://w3id.org/biolink/vocab/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX taxon: <http://purl.obolibrary.org/obo/NCBITaxon_>

SELECT ?protein ?protein_label ?gene ?gene_label
WHERE {
  ?protein a biolink:Protein ;
           biolink:associated_with ex:Type2Diabetes ;
           biolink:encoded_by ?gene ;
           biolink:in_taxon taxon:9606 ;
           rdfs:label ?protein_label .
  ?gene rdfs:label ?gene_label .
}
"
result1 <- run_query(q1)
View(as.data.frame(result1))

#CONSULTA 2: Procesos biológicos en los que participan proteínas asociadas a DM2
q2 <- "
PREFIX ex: <https://um.es/diabetes/>
PREFIX biolink: <https://w3id.org/biolink/vocab/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT DISTINCT ?process ?process_label ?protein
WHERE {
  ?protein a biolink:Protein ;
           biolink:associated_with ex:Type2Diabetes ;
           biolink:participates_in ?process .
  ?process a biolink:BiologicalProcess ;
           rdfs:label ?process_label .
}
"
result2 <- run_query(q2)
View(as.data.frame(result2))

#CONSULTA 3: Fenotipos asociados a DM2 y proteínas relacionadas con ellos
q3 <- "
PREFIX ex: <https://um.es/diabetes/>
PREFIX biolink: <https://w3id.org/biolink/vocab/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?phenotype ?phenotype_label ?protein ?protein_label
WHERE {
  ex:Type2Diabetes biolink:has_phenotype ?phenotype .
  ?phenotype rdfs:label ?phenotype_label .

  ?protein a biolink:Protein ;
           biolink:associated_with ex:Type2Diabetes ;
           rdfs:label ?protein_label .
}
"
result3 <- run_query(q3)
View(as.data.frame(result3))

# CONSULTA 4: Mutaciones asociadas a DM2, genes/proteínas afectadas y fármacos

q4 <- "
PREFIX ex: <https://um.es/diabetes/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT DISTINCT
       ?mutation
       ?mutation_label
       ?gene
       ?gene_label
       ?protein
       ?protein_label
       ?drug
       ?drug_label
WHERE {
  # Enfermedad y mutaciones
  ex:Type2Diabetes ex:causadaPor ?mutation .
  ?mutation rdfs:label ?mutation_label ;
            ex:afectaGen ?gene ;
            ex:reduce_expresion ?protein ;
            ex:tratadaCon ?drug .

  # Etiquetas
  ?gene rdfs:label ?gene_label .
  ?protein rdfs:label ?protein_label .
  ?drug rdfs:label ?drug_label .
}
"
result4 <- run_query(q4)
View(as.data.frame(result4))

#CONSULTA 5 (FEDERADA): Proteínas asociadas a DM2 implicadas específicamente en señalización de insulina 
q5 <- "
PREFIX ex: <https://um.es/diabetes/>
PREFIX biolink: <https://w3id.org/biolink/vocab/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?protein ?protein_label ?external_label
WHERE {
  ?protein a biolink:Protein ;
           biolink:associated_with ex:Type2Diabetes ;
           biolink:participates_in ex:InsulinSignaling ;
           rdfs:label ?protein_label .

  SERVICE <https://sparql.uniprot.org/sparql> {
    ?protein rdfs:label ?external_label .
  }
}
"
result5 <- run_query(q5)
View(as.data.frame(result5))
