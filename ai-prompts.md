# AI Prompts

Prompts given to the AI assistant (Claude), in order.
Note: prompts 1–26 were added in one commit during Part 2. I missed adding them
with each earlier commit. From prompt 27 on, they are committed with their changes.

---

## 1
I'm doing a DevOps technical exercise (attached). My deadline is 15:00 – about 2 hours from now.

Already installed on my Mac: Docker Desktop, kind, kubectl, Terraform, Helm, git, gh (logged in), VS Code.

How I want to work:
- Go part by part, in the order of the exercise.
- For each part: first explain what is needed and the options with trade-offs. I decide, and only then you write the code.
- Professional, but no over-engineering – I need to be able to explain every line in the review.
- Code comments in English and short. In config files (Dockerfile, manifests, Terraform, workflows), mark the sections so they are easy to navigate.
- Give exact file paths and full file contents.
- After each part I run it, verify it, commit and push. Remind me to git pull before changes once CI starts committing.
- Add simple automated checks in CI where they add real value.
- Everything in the repo must be in English: code, comments, README, commit messages and the prompts file.
- Reply in Hebrew, with English technical terms on separate lines.

Decisions I already made: Node.js with Express for the service, repo name devops-exercise, kind for the local cluster.

I'm first will add the mission here.

## 2
[Attached: DevOps_Technical_Exercise_-_Candidate_Instructions.pdf]
write in this conversation in english please.

## 3
please write me the terminal lines to start this project, im currently in the project dir in my mac. i need to mkdir new dir with the name of this project. the dir will be name devops-mission-lahav-rabinovitz

## 4
please match the repo name. change it to the same name .

## 5
i did the brew and install all the things needed from steos 3-5.
now let's go to the mission steps.
let's do part by part.
sand me what u think and i will approve it and than we will move forward

## 6
got with the readme after we need to commit it and than finish with part 0.

## 7
[Attached: screenshot of the VS Code file explorer]
this is what i have i add the gitignore and past the file.
now just to commit it, check if it is ok

## 8
it is pushed.

## 9
i still don't see it in github after commit 2, i need to sync it

## 10
let's go to the begging of commit 3.

## 11
this is the readme, please rewrite it here after the changes.
[Pasted: my README.md, which was cut off after "## Repository layout"]

## 12
done. lets got to the nest part

## 13
those lines are according to your recommendation ?

## 14
i want to go with your recommendations.
this is the outputs:
[Pasted: helm search output (argo-cd chart 10.14.0, traefik chart 42.3.1) and kind version v0.33.0]

## 15
wait before all of this, you are go accroding to the mission rules?
with the want to sand all the chat here?
i need to sand it in the end?

## 16
before i run the vberify, i want u to explain me ths outputs.tf file and the addons.tf file and the versions please.

## 17
[Attached: terraform apply output – Traefik failed: "at '/service': additional properties 'type' not allowed"]
im now here:

## 18
[Pasted: helm show values traefik/traefik --version 42.3.1 – the service section]

## 19
[Pasted: kubectl get nodes / pods and curl http://localhost → 404 from Traefik]

## 20
[Pasted: git add error – I ran it from inside terraform/]

## 21
[Pasted: pwd and git status from the repo root]

## 22
just before look at this  and confirm it is ok:
[Pasted: commit output and git status showing untracked terraform/devops-config]

## 23
let's go again to part 2, write it again please.

## 24
I approving it according to your recommendations as we did in exercise

## 25
[Pasted: docker images and kind load docker-image output]

## 26
i add the 5 file please write again the readme with the changes so i could past it inside my project. after lt's commit it

## 27
[Pasted: git add error "pathspec 'argocd' did not match any files"]
another thing - i didnt add anything to the ai-prompts.md it is empty.


## 28
[Attached: screenshot of the VS Code file explorer – application.yaml was inside k8s/]
write for me the remove files from folders that are not correct please.

## 29
before the commit look at the status:
[Pasted: git status – README.md and ai-prompts.md modified, argocd/ and k8s/ untracked]

## 30
[Pasted: kubectl apply -f argocd/application.yaml and verification – Synced/Progressing, 2 pods on different workers, curl loop alternating between both pods]

## 31
lets go as we did before in the home exercise.
start please.

## 32
where to put the scripts/load...

## 33
[Pasted: git add error "pathspec '.github/workflows/ci-cd.yaml' did not match any files"]

## 34
[Pasted: find output – the workflow was at .github/ci-cd.yaml]

## 35
[Attached: screenshot of the VS Code file explorer]
before the commit chack if the files is correct now:

## 36
[Attached: ai-prompts.md]
this is the ai-promtds file please add what needed: