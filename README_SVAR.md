# Begrunnelser
## 1B — CI-pipeline "Tagging strategi"
### Benyttet SHA og kuttet den ned til de 7 første tegnene
- Valgt SHA for å enkelt kunne se hvilken versjon av prosjektet som kjører hvor.
- Kuttet det ned til de 7 første sifferene for å videre forenkle lesbarheten.
- De 7 første sifferene i SHA'en gir god nok sannsynlighet for at det ikke oppstår navne-duplikater.
- "Lenke til grønn kjøring": https://github.com/Hovercraft97/DevOpsExam2026/actions/runs/41096262443

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

## 3A - Metrikker
Alle metrikker publiseres til CloudWatch-namespacet `wishifai-8`.

### Konfigurasjon
- **Namespace:** Var tomt i `MetricsConfig`, og da ble ingen metrikker publisert. Det settes nå fra Terraform (`local.metrics_namespace`) via miljøvariabelen `METRICS_NAMESPACE`, slik at appen og IAM bruker samme verdi.
- **Task-rollen:** Har fått `cloudwatch:PutMetricData`, begrenset med `condition` til eget namespace (minste privilegium).

### Tekniske metrikker
- `wishifai.rekognition.duration` (`Timer`) måler tiden Rekognition-kallet tar.
- `wishifai.bedrock.duration` (`Timer`) måler tiden Bedrock-kallet tar.
- Kun selve AWS-kallene måles, ikke prompt-bygging eller parsing, slik at tallene viser AWS-tjenestenes svartid.

### Business-metrikk: `wishifai.gift.suggestions` (`DistributionSummary`)
Registrerer antall gaveforslag for hver fullførte analyse.
- `.count` gir antall bilder analysert og viser hvor mye tjenesten brukes.
- `.sum` gir totalt antall gaveforslag generert.
- `.avg` gir gjennomsnittlig antall forslag pr. analyse.

**Hvorfor:** Metrikken måler hva tjenesten faktisk leverer til brukerne, ikke bare om den kjører. Hver analyse koster penger i Rekognition- og Bedrock-kall. Ved å sammenligne `.count` med AWS-kostnadene kan man se hva hver leverte gaveliste koster, og vurdere om tjenesten er lønnsom.

**Hvorfor i `WishlistService`:** Tjenesten bestemmer rekkefølgen og sender data mellom S3, Rekognition og Bedrock. Den er derfor det eneste stedet som vet at en hel analyse er fullført.