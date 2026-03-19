# Understanding Git

From: <a href="https://www.youtube.com/watch?v=Ala6PHlYjmw">Learn that stack</a>

Git is a database, made of commits.

Commits are snapshots of the entire db (all files at that point in time).

Git doesnt track changes, it tracks the state of files.

Commits contain 3 things:

- Snapshot, state of all files at the time
- Metadata, who created it, when, comment
- Pointer backwards to the parent commit

Each commit points to its parent, and down the chain to the beginning.

Commit0 <- Commit1 <- Commit2 <- Commit3

The first commit has no parent, origin point.

Branches will have two parents when merged.

Branches are simpler than most people think. Treat them like sticky notes.

Branches are not separate copies of the code base, its just a pointer, the hash of a commit. The branch simply points (its a pointer) to branch a1b2c3d etc...

Branches do not contain commits, they point at commits. 

Main is just another pointer to the primary line of work.

Head says where you are working at. It points to a branch.

HEAD -> MAIN -> Some commit

If you checkout a specific commit previous to that branch it will be a detached HEAD. You can commit but they are orphaned, if you commit it will probably be garbage collected.

Git has 3 areas where code can live.

- Working dir
- Staging area/index
- Repo (permanent history)

Working Dir -> git add -> Staging Area -> git commit -> Repo

Three main commands

- checkout
    - move head
    - non destructive, just moves your viewpoint, could be detached
- reset
    - move branch
    - this can move main to a specific commit hash
        - soft reset, moved branch only
        - mixed reset, moves branch and staging, need to restage
        - hard reset, moves everything, files change, uncommited work destroyed
- revert
    - add commit
    - creates new commit that does the opposite of another commit
        +50 lines, now -50 lines

Rebase, this is when your feature branch and main have independently moved forward with commits. 

You can merge using both main and the feature as parents. Or, you can rebase which takes your branch commits and replays them on top of the new main. 

Branch B<-C
Main A<-X<-Y

Rebase will not be A B C X Y

It will be A<-X<-Y<-B1<-C1

Git will then remove the branch, old B and C will be orphaned.

git reflog, this will show where head has been pointed recently. Find the hash of your work, `git branch recovery SOMEHASH` and you will have your work back.

