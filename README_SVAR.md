# Begrunnelser
## 1B — CI-pipeline "Tagging strategi"
### Benyttet SHA og kuttet den ned til de 7 første tegnene
- Valgt SHA for å enkelt kunne se hvilken versjon av prosjektet som kjører hvor.
- Kuttet det ned til de 7 første sifferene for å videre forenkle lesbarheten.
- De 7 første sifferene i SHA'en gir god nok sannsynlighet for at det ikke oppstår navne-duplikater.
- "Lenke til grønn kjøring": https://github.com/Hovercraft97/DevOpsExam2026/actions/runs/41096262443

## 2A - Offentlig url til tjenesten
### Fra Outputs.tf:
- service_url = "https://wi-cd7933da93df464a8dcae5b5a47dc91e.ecs.eu-west-1.on.aws"

## 2B - Valgt nøkkel
### Benyttet kandidatnummer
- ```key = "wishifai/8/terraform.tfstate"```
- Nøkkelen inneholder kandidatnummeret ```8```, slik at state-filen er unik og ikke kolliderer med andre kandidater i den delte bucketen.
- Kandidatnummeret er hardkodet i backend-blokken fordi Terraform ikke tillater variabler i backend-konfigurasjon.
- ```use_lockfile = true``` gir state-låsing direkte i S3, slik at to samtidige kjøringer ikke kan overskrive hverandre.
- ```encrypt = true``` krypterer state-filen, siden den kan inneholde sensitive verdier.

## 2C - Terraform begrunnelse
### Hvorfor er det fornuftig at Terraform kjører etter container-build, og ikke parallelt eller før?
- Imaget må finnes i ECR før Terraform kan deploye det.
### Lenke til grønn kjøring:
- https://github.com/Hovercraft97/DevOpsExam2026/actions/runs/41686312781

## 3A - Metrikker
Alle metrikker publiseres til CloudWatch-namespacet `wishifai-8`.

### Konfigurasjon
- **Namespace:** Var tomt i `MetricsConfig`, og da ble ingen metrikker publisert. Det settes nå fra Terraform (`local.metrics_namespace`) via miljøvariabelen `METRICS_NAMESPACE`, slik at appen og IAM bruker samme verdi.
- **Task-rollen:** Har fått `cloudwatch:PutMetricData`, begrenset med `condition` til eget namespace (minste privilegium).

### Tekniske metrikker
- `wishifai.rekognition.duration` (`Timer`) måler tiden Rekognition-kallet tar.
- `wishifai.bedrock.duration` (`Timer`) måler tiden Bedrock-kallet tar.
- Kun selve AWS-kallene måles, slik at tallene viser AWS-tjenestenes svartid.

### Business-metrikk: 
`wishifai.gift.suggestions` (`DistributionSummary`)
Registrerer antall gaveforslag for hver fullførte analyse.
- `.count` gir antall bilder analysert og viser hvor mye tjenesten brukes.
- `.sum` gir totalt antall gaveforslag generert.
- `.avg` gir gjennomsnittlig antall forslag pr. analyse.

**Hvorfor:** Metrikken måler hva tjenesten faktisk leverer til brukerne, ikke bare om den kjører. Hver analyse koster penger i Rekognition- og Bedrock-kall. Ved å sammenligne `.count` med AWS-kostnadene kan man se hva hver leverte gaveliste koster, og vurdere om tjenesten er lønnsom.

**Hvorfor i `WishlistService`:** Tjenesten bestemmer rekkefølgen og sender data mellom S3, Rekognition og Bedrock. Den er derfor det eneste stedet som vet at en hel analyse er fullført.

## 3B - Dashboard og alarm
### Dashboard: `wishifai-8` (CloudWatch, eu-west-1)
![Dashboard](/media/Dashboard_wishifai-8.png)
### Business
- `wishifai.gift.suggestions.count` (Sum pr. 5 min) viser hvor mange bilder som analyseres, altså hvor mye tjenesten brukes.
- `wishifai.gift.suggestions.avg` viser antall gaveforslag pr. analyse. Den ligger stabilt på 5 fordi prompten ber om inntil 5 forslag. Et fall betyr at Bedrock gir færre eller ugyldige svar (appen faller da tilbake til ett "(ukjent format)"-forslag). Det er en kvalitetsfeil som ikke vises som teknisk feil.

### Infrastruktur
- `CPUUtilization` og `MemoryUtilization` viser om containeren har nok ressurser. CPU-grafen har en linje på 60 % som tilsvarer autoskaleringsgrensen i `ecs.tf`.
- `LiveTaskCount` viser antall aktive tasks, og om autoskaleringen slår inn. 

### Applikasjon
- HTTP-latens på `/api/analyze` vises sammen med `wishifai.bedrock.duration` og `wishifai.rekognition.duration` i samme graf. Da ser man hvor stor andel av svartiden brukeren opplever som går til de eksterne AWS-kallene.
- JVM heap og GC-tid (Garbage collection) pr. minutt viser om JVM-en selv er årsaken til treghet.
- Metrikkene hentes med `SEARCH()` fordi Actuator legger på mange dimensjoner og kombinasjonene er ukjent på forhånd.

### Hvorfor denne sammensetningen
Radene skal sammen svare på hvor tiden blir av. Er HTTP-latensen høy mens CPU, minne og GC er lave, ligger flaskehalsen i de eksterne AWS-kallene og ikke i containeren eller JVM-en.

### Alarm: `wishifai-8-bedrock-latency-high`
- **Hva:** Går når snittet av `wishifai.bedrock.duration.avg` er over 20 sekunder i 3 av 5 minutter.
- **Hvorfor:** Målt over 10 analyser tar `/api/analyze` i snitt 16,4 s, hvorav Bedrock 15,2 s og Rekognition 0,8 s. Bedrock er derfor der treghet mest sannsynlig oppstår (Målingene er tatt en stund etter deployment).
- **Terskel:** 20 s fanger reell forverring uten å reagere på vanlige svingninger.