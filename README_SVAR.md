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
- ```use_lockfile = true``` gir state-låsing direkte i S3, slik at to samtidige kjøringer ikke kan skrive over hverandre.
- ```encrypt = true``` krypterer state-filen, siden den kan inneholde sensitive verdier.

