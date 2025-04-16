// api.mjs - Common git operations

import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';

/**
 * Check if the current directory is a Git repository
 * @returns {boolean} True if it's a Git repository
 */
export function isGitRepository() {
  try {
    execSync('git rev-parse --is-inside-work-tree', { stdio: 'ignore' });
    return true;
  } catch (error) {
    return false;
  }
}

/**
 * Get the current branch name
 * @returns {string} Current branch name
 */
export function getCurrentBranch() {
  try {
    return execSync('git branch --show-current', { encoding: 'utf8' }).trim();
  } catch (error) {
    throw new Error('Failed to get current branch: ' + error.message);
  }
}

/**
 * Get all local branches
 * @returns {string[]} Array of branch names
 */
export function getLocalBranches() {
  try {
    const output = execSync('git branch', { encoding: 'utf8' });
    return output
      .split('\n')
      .filter(Boolean)
      .map(branch => branch.replace(/^\*?\s*/, '').trim());
  } catch (error) {
    throw new Error('Failed to get local branches: ' + error.message);
  }
}

/**
 * Delete a local branch
 * @param {string} branchName Branch to delete
 * @param {boolean} force Whether to force deletion
 * @returns {object} Result of the operation
 */
export function deleteLocalBranch(branchName, force = false) {
  try {
    const flag = force ? '-D' : '-d';
    execSync(`git branch ${flag} ${branchName}`, { encoding: 'utf8' });
    return { success: true, message: `Branch ${branchName} deleted successfully` };
  } catch (error) {
    return { 
      success: false, 
      message: `Failed to delete branch ${branchName}: ${error.message}`,
      requireForce: !force && error.message.includes('not fully merged')
    };
  }
}

/**
 * Get remote repositories
 * @returns {string[]} Array of remote names
 */
export function getRemotes() {
  try {
    const output = execSync('git remote', { encoding: 'utf8' });
    return output.split('\n').filter(Boolean);
  } catch (error) {
    throw new Error('Failed to get remotes: ' + error.message);
  }
}

/**
 * Execute generic git command and return its output
 * @param {string} command Git command to execute
 * @returns {string} Command output
 */
export function executeGitCommand(command) {
  try {
    return execSync(`git ${command}`, { encoding: 'utf8' });
  } catch (error) {
    throw new Error(`Failed to execute 'git ${command}': ${error.message}`);
  }
}