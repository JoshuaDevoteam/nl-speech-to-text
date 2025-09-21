# GOOGLE CLOUD TERRAFORM MODULES

## PULL REQUEST GUIDELINES

Read and follow the contributing guidelines and code of conduct for the project. Here are screenshots of where to find
them for [**first time
contributors**](https://opensource.creativecommons.org/contributing-code/pr-guidelines/first-time-contributor-resources.png)
and [**previous
contributors**](https://opensource.creativecommons.org/contributing-code/pr-guidelines/previous-contributor-resources.png).

- Make A Branch
  - Please create a separate branch for each issue that you're working on. Do not make changes to the default branch (
    e.g.`main`,`develop`) of your fork.
- Push Your Code ASAP
  - Push your code as soon as you can. Follow the "[**early and
    often**](https://www.worklytics.co/blog/commit-early-push-often/)" rule.
  - Make a pull request as soon as you can and mark the title with a "[WIP]". You can create
    a [draft pull request](https://help.github.com/en/articles/about-pull-requests#draft-pull-requests).\
    [Screenshot: How to create draft PR?](https://opensource.creativecommons.org/contributing-code/pr-guidelines/draft_pr.gif)
- Describe Your Pull Request
  - Use the format specified in pull request template for the repository. Populate the stencil completely for maximum
    verbosity.
    - Tag the actual issue number by replacing `#[issue_number]` e.g. `#42`. This closes the issue when your PR is
      merged.
    - Tag the actual issue author by replacing `@[author]` e.g. `@issue_author`. This brings the reporter of the issue
      into the conversation.
    - Mark the tasks off your checklist by adding an `x` in the `[ ]` e.g. `[x]`. This checks off the boxes in your
      to-do list. The more boxes you check, the better.
  - Describe your change in detail. Too much detail is better than too little.
  - Describe how you tested your change.
  - Check the Preview tab to make sure the Markdown is correctly rendered and that all tags and references are linked.
    If not, go back and edit the Markdown.\
    [Screenshot: Populated pull request](https://opensource.creativecommons.org/contributing-code/pr-guidelines/populated_pr.png)
- Request Review
  - Once your PR is ready, remove the "[WIP]" from the title and/or change it from a draft PR to a regular PR.
  - If a specific reviewer is not assigned automatically,
    please [request a review](https://help.github.com/en/articles/requesting-a-pull-request-review) from the project
    maintainer and any other interested parties manually.
- Incorporating feedback
  - If your PR gets a 'Changes requested' review, you will need to address the feedback and update your PR by pushing to
    the same branch. You don't need to close the PR and open a new one.
  - Be sure to re-request review once you have made changes after a code review.\
    [Screenshot: How to request re-review?](https://opensource.creativecommons.org/contributing-code/pr-guidelines/rereview.png)
  - Asking for a re-review makes it clear that you addressed the changes that were requested and that it's waiting on
    the maintainers instead of the other way round.\
    [Screenshot: Difference between 'Changes requested' and 'Review required'](https://opensource.creativecommons.org/contributing-code/pr-guidelines/difference.png)

CODE GUIDELINES
---------------

- Write comprehensive and robust tests that cover the changes you've made in your work.
- Follow the appropriate code style standards for the language and framework you're using (e.g. PEP 8 for Python).
- Write readable code -- keep functions small and modular and name variables descriptively.
- Document your code thoroughly.
- Make sure all the existing tests pass.

## COMMITS STRUCTURE

The commit message should be structured as follows:

```
<type>[optional scope]: <description>
[optional body]
[optional footer]
```

The commit contains the following structural elements, to communicate intent to the consumers of your library:

**fix:** a commit of the type fix patches a bug in your codebase (this correlates with PATCH in semantic versioning).

feat: a commit of the type feat introduces a new feature to the codebase (this correlates with MINOR in semantic
versioning).

BREAKING CHANGE: a commit that has the text BREAKING CHANGE: at the beginning of its optional body or footer section
introduces a breaking **_API/resource_** change (correlating with MAJOR in semantic versioning).

A breaking change can be part of commits of any type. e.g., a fix:, feat: & chore: types would all be valid, in addition
to any other type.

Others: commit types other than fix: and feat: are allowed, for example (based on the Angular convention) recommends
**_chore:, docs:, style:, refactor:, perf:, test:, and others_**.

## EXAMPLES OF COMMITS

**Commit message with description and breaking change in body**

```
feat: allow provided config object to extend other configs

BREAKING CHANGE: `extends` key in config file is now used for extending other config files
```

**Commit message with no body**

```
docs: correct spelling of README
```

or

```
chore: module initialization
```

**Commit message with scope**

```
feat(module): added module x
```

**Commit message for a fix using an (optional) issue number.**

```
fix: minor typos in code
```

**Commit message when an issue was fixed**

```
fix: fixes issue #1
```

## SPECIFICATIONS

1. Commits MUST be prefixed with a type, which consists of a noun, `feat`, `fix`, `chore` etc., followed by a colon and
   a space.
2. The type feat MUST be used when a commit adds a new feature to your application or library.
3. The type fix MUST be used when a commit represents a bug fix for your application.
4. An optional scope MAY be provided after a type. A scope is a phrase describing a section of the codebase enclosed in
   parentheses, e.g., `fix(module)`:
5. A description MUST immediately follow the type/scope prefix. The description is a short description of the code
   changes, e.g., `fix: array parsing issue when multiple spaces were contained in string`.
6. A longer commit body MAY be provided after the short description, providing additional contextual information about
   the code changes. The body MUST begin one blank line after the description.
7. A footer MAY be provided one blank line after the body (or after the description if body is missing). The footer
   SHOULD contain additional issue references about the code changes (such as the issues it fixes, e.g.,Fixes #13).
8. Breaking changes MUST be indicated at the very beginning of the footer or body section of a commit. A breaking change
   MUST consist of the uppercase text BREAKING CHANGE, followed by a colon and a space.
9. A description MUST be provided after the `BREAKING CHANGE: , describing what has changed about the API`,
   e.g., `BREAKING CHANGE: environment variables now take precedence over config files`.
10. The footer MUST only contain `BREAKING CHANGE`, external links, issue references, and other meta-information.
11. Types other than feat and fix MAY be used in your commit messages.

## FAQ COMMITS

**How should I deal with commit messages in the initial development phase?**

We recommend that you proceed as if you’ve an already released product. Typically somebody, even if its your fellow
software developers, is using your software. They’ll want to know what’s fixed, what breaks etc.

**What do I do if the commit conforms to more than one of the commit types?**

Go back and make multiple commits whenever possible. Part of the benefit of Conventional Commits is its ability to drive
us to make more organized commits and PRs.

**Doesn’t this discourage rapid development and fast iteration?**

It discourages moving fast in a disorganized way. It helps you be able to move fast long term across multiple projects
with varied contributors.

**What do I do if I accidentally use the wrong commit type?**

When you used a type that’s of the spec but not the correct type, e.g. fix instead of feat Prior to merging or releasing
the mistake, we recommend using git rebase -i to edit the commit history. After release, the cleanup will be different
according to what tools and processes you use.

**When you used a type not of the spec, e.g. feet instead of feat**?
In the worst case scenario, it’s not the end of the
world if a commit lands that does not meet the conventional commit specification. It simply means that commit will be
missed by tools that are based on the spec.

**Do all my contributors need to use the conventional commit specification?**

No! If you use a squash based workflow on Git lead maintainers can clean up the commit messages as they’re merged—adding
no workload to casual committers.

A common workflow for this is to have your git system automatically squash commits from a pull request and present a
form for the lead maintainer to enter the proper git commit message for the merge.

_General guidelines and best practices from [**Conventional
commits**](https://www.conventionalcommits.org/en/v1.0.0-beta.2/)_
and [**Pull Request Guidelines**](https://opensource.creativecommons.org/contributing-code/pr-guidelines/) from Open
Source CC.

## CONTRIBUTING

Install the following tools:

    pre-commit gawk terraform-docs tflint tfsec coreutils checkov

After having installed all these tools, run the following command in the repo directory to install [pre-commit] into
your Git hooks:

    pre-commit install

`pre-commit` will now run on every commit.

Every time you clone a project, running `pre-commit install` should always be the first thing you do.

The configuration for `pre-commit` is in the `.pre-commit-config.yaml` file.

[pre-commit]: https://pre-commit.com/

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app-engine"></a> [app-engine](#module\_app-engine) | ./tf-gcp-app-engine | v0.0.2 |
| <a name="module_atlantis"></a> [atlantis](#module\_atlantis) | ./tf-gcp-atlantis | v0.0.2 |
| <a name="module_cloud-build"></a> [cloud-build](#module\_cloud-build) | ./tf-gcp-cloud-build | v0.0.2 |
| <a name="module_cloud-composer"></a> [cloud-composer](#module\_cloud-composer) | ./tf-gcp-cloud-composer | v0.0.2 |
| <a name="module_cloud-function"></a> [cloud-function](#module\_cloud-function) | ./tf-gcp-cloud-function | v0.0.2 |
| <a name="module_cloud-run"></a> [cloud-run](#module\_cloud-run) | ./tf-gcp-cloud-run | v0.0.2 |
| <a name="module_cloud-scheduler"></a> [cloud-scheduler](#module\_cloud-scheduler) | ./tf-gcp-cloud-scheduler | v0.0.2 |
| <a name="module_cloud-sql"></a> [cloud-sql](#module\_cloud-sql) | ./tf-gcp-cloud-sql | v0.0.2 |
| <a name="module_cloud-storage"></a> [cloud-storage](#module\_cloud-storage) | ./tf-gcp-cloud-storage | v0.0.2 |
| <a name="module_compute-engine"></a> [compute-engine](#module\_compute-engine) | ./tf-gcp-compute-engine | v0.0.2 |
| <a name="module_firestore"></a> [firestore](#module\_firestore) | ./tf-gcp-firestore | v0.0.2 |
| <a name="module_gke"></a> [gke](#module\_gke) | ./tf-gcp-gke | v0.0.2 |
| <a name="module_iam"></a> [iam](#module\_iam) | ./tf-gcp-iam | v0.0.2 |
| <a name="module_memorystore"></a> [memorystore](#module\_memorystore) | ./tf-gcp-memorystore | v0.0.2 |
| <a name="module_project"></a> [project](#module\_project) | ./tf-gcp-project | v0.0.2 |
| <a name="module_pubsub"></a> [pubsub](#module\_pubsub) | ./tf-gcp-pubsub | v0.0.2 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./tf-gcp-vpc | v0.0.2 |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
