> :warning: **IMPORTANT**
> This module is early in it´s development phase. Many API function and features are not yet available. You are welcome to contribute on GitHub to accelerate progress further.

# PSQueue

This project has adopted the following policies [![CodeOfConduct](https://img.shields.io/badge/Code%20Of%20Conduct-gray)](https://github.com/hanpq/PSQueue/blob/main/.github/CODE_OF_CONDUCT.md) [![Contributing](https://img.shields.io/badge/Contributing-gray)](https://github.com/hanpq/PSQueue/blob/main/.github/CONTRIBUTING.md) [![Security](https://img.shields.io/badge/Security-gray)](https://github.com/hanpq/PSQueue/blob/main/.github/SECURITY.md)

## Project status
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/hanpq/PSQueue/build.yml?branch=main&label=build&logo=github)](https://github.com/hanpq/PSQueue/actions/workflows/build.yml) [![Codecov](https://img.shields.io/codecov/c/github/hanpq/PSQueue?logo=codecov&token=qJqWlwMAiD)](https://codecov.io/gh/hanpq/PSQueue) [![Platform](https://img.shields.io/powershellgallery/p/PSQueue?logo=ReasonStudios)](https://img.shields.io/powershellgallery/p/PSQueue) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PSQueue?label=downloads)](https://www.powershellgallery.com/packages/PSQueue) [![License](https://img.shields.io/github/license/hanpq/PSQueue)](https://github.com/hanpq/PSQueue/blob/main/LICENSE) [![docs](https://img.shields.io/badge/docs-getps.dev-blueviolet)](https://getps.dev/modules/PSQueue/getstarted) [![changelog](https://img.shields.io/badge/changelog-getps.dev-blueviolet)](https://github.com/hanpq/PSQueue/blob/main/CHANGELOG.md) ![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/hanpq/PSQueue?label=version&sort=semver) ![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/hanpq/PSQueue?include_prereleases&label=prerelease&sort=semver)

## About

PSQueue is a wrapper module for the .Net class System.Collections.Queue. This module mainly provides two benefits, the first is to make it easy to utilize the queue class in a powershell syntax way. The second reason is that queue objects created with this module adds additional functionality like metrics for items added and removed, counters for items added and removed per second and velocity. Every time an item is added or removed these performance metrics are calculated. This of course adds a small overhead and decreases performance and is very marginal. Unless the queue will process more than tens of thousands of addition and removals per sec it will not be noticeable.


## Installation

### PowerShell Gallery

To install from the PowerShell gallery using PowerShellGet run the following command:

```powershell
Install-Module PSQueue -Scope CurrentUser
```

## Usage

Start by initialize a new queue object

``` powershell
$Queue = Initialize-Queue
```

To add a new item to the queue use Add-QueueItem

``` powershell
Add-QueueItem -Queue $Queue -Item 'Foo'
```

To retreive the next item in queue use Get-NextQueueItem

``` powershell
$NextItemToProcess = Get-NextQueueItem -Queue $Queue
```

You can also "peek" at the next item in queue by using Show-NextQueueItem, the difference from Get-NextQueueItem is that the next item in queue is retreived but remains in the queue.

``` powershell
$NextItemInQueue = Show-NextQueueItem -Queue $Queue
```

You have two methods of emptying the queue, either by retreiving all items (Get-AllQueueItems) or by discarding all items (Clear-AllQueueItems)
``` powershell

# This will retreive all items and dequeue the items. 
$AllRemainingQueueItems = Get-AllQueueItems -Queue $Queue

# This will also clear the queue but it does not return any items for the queue and is therefor faster
Clear-AllQueueItems -Queue $Queue

```

You can show performance metrics by using Measure-Queue
``` powershell
Measure-Queue -Queue $Queue
```
